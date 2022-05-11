package svc

import (
	"net/http"
	"time"

	"github.com/cs3org/reva/v2/pkg/rgrpc/todo/pool"
	"github.com/owncloud/ocis/ocis-pkg/service/grpc"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/render"

	accountssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/accounts/v0"

	"github.com/owncloud/ocis/ocis-pkg/account"
	"github.com/owncloud/ocis/ocis-pkg/log"
	opkgm "github.com/owncloud/ocis/ocis-pkg/middleware"
	"github.com/owncloud/ocis/ocis-pkg/roles"
	"github.com/owncloud/ocis/ocs/pkg/config"
	ocsm "github.com/owncloud/ocis/ocs/pkg/middleware"
	"github.com/owncloud/ocis/ocs/pkg/service/v0/data"
	"github.com/owncloud/ocis/ocs/pkg/service/v0/response"
	settingssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/settings/v0"
	"github.com/owncloud/ocis/proxy/pkg/user/backend"
)

// Service defines the extension handlers.
type Service interface {
	ServeHTTP(http.ResponseWriter, *http.Request)
	GetConfig(http.ResponseWriter, *http.Request)
}

// NewService returns a service implementation for Service.
func NewService(opts ...Option) Service {
	options := newOptions(opts...)

	m := chi.NewMux()
	m.Use(options.Middleware...)

	roleService := options.RoleService
	if roleService == nil {
		roleService = settingssvc.NewRoleService("com.owncloud.api.settings", grpc.DefaultClient)
	}
	roleManager := options.RoleManager
	if roleManager == nil {
		m := roles.NewManager(
			roles.CacheSize(1024),
			roles.CacheTTL(time.Hour*24*7),
			roles.Logger(options.Logger),
			roles.RoleService(roleService),
		)
		roleManager = &m
	}

	svc := Ocs{
		config:      options.Config,
		mux:         m,
		RoleManager: roleManager,
		logger:      options.Logger,
	}

	if svc.config.AccountBackend == "" {
		svc.config.AccountBackend = "accounts"
	}

	requireUser := ocsm.RequireUser(
		ocsm.Logger(options.Logger),
	)

	requireAdmin := ocsm.RequireAdmin(
		ocsm.RoleManager(roleManager),
		ocsm.Logger(options.Logger),
	)

	requireSelfOrAdmin := ocsm.RequireSelfOrAdmin(
		ocsm.RoleManager(roleManager),
		ocsm.Logger(options.Logger),
	)
	m.Route(options.Config.HTTP.Root, func(r chi.Router) {
		r.NotFound(svc.NotFound)
		r.Use(middleware.StripSlashes)
		r.Use(opkgm.ExtractAccountUUID(
			account.Logger(options.Logger),
			account.JWTSecret(options.Config.TokenManager.JWTSecret)),
		)
		r.Use(ocsm.OCSFormatCtx) // updates request Accept header according to format=(json|xml) query parameter
		r.Route("/v{version:(1|2)}.php", func(r chi.Router) {
			r.Use(response.VersionCtx) // stores version in context
			r.Route("/apps/files_sharing/api/v1", func(r chi.Router) {})
			r.Route("/apps/notifications/api/v1", func(r chi.Router) {})
			r.Route("/cloud", func(r chi.Router) {
				r.Route("/capabilities", func(r chi.Router) {})
				// TODO /apps
				r.Route("/user", func(r chi.Router) {
					r.With(requireSelfOrAdmin).Get("/", svc.GetSelf)
					r.Get("/signing-key", svc.GetSigningKey)
				})

				// for /users endpoints see https://github.com/owncloud/core/blob/master/apps/provisioning_api/appinfo/routes.php#L44-L56
				r.Route("/users", func(r chi.Router) {
					r.With(requireAdmin).Get("/", svc.ListUsers)
					r.With(requireAdmin).Post("/", svc.AddUser)
					r.Route("/{userid}", func(r chi.Router) {
						r.With(requireUser).Get("/", svc.GetUser)
						r.With(requireSelfOrAdmin).Put("/", svc.EditUser)
						r.With(requireAdmin).Delete("/", svc.DeleteUser)
						r.With(requireAdmin).Put("/enable", svc.EnableUser)
						r.With(requireAdmin).Put("/disable", svc.DisableUser)
					})

					r.Route("/{userid}/groups", func(r chi.Router) {
						r.With(requireSelfOrAdmin).Get("/", svc.ListUserGroups)
						r.With(requireAdmin).Post("/", svc.AddToGroup)
						r.With(requireAdmin).Delete("/", svc.RemoveFromGroup)
					})

					r.Route("/{userid}/subadmins", func(r chi.Router) {
						r.With(requireAdmin).Post("/", svc.NotImplementedStub)
						r.With(requireSelfOrAdmin).Get("/", svc.NotImplementedStub)
						r.With(requireAdmin).Delete("/", svc.NotImplementedStub)
					})
				})

				// for /groups endpoints see https://github.com/owncloud/core/blob/master/apps/provisioning_api/appinfo/routes.php#L65-L69
				r.Route("/groups", func(r chi.Router) {
					r.With(requireAdmin).Get("/", svc.ListGroups)
					r.With(requireAdmin).Post("/", svc.AddGroup)
					r.With(requireSelfOrAdmin).Get("/{groupid}", svc.GetGroupMembers)
					r.With(requireAdmin).Delete("/{groupid}", svc.DeleteGroup)
					r.With(requireAdmin).Get("/{groupid}/subadmins", svc.NotImplementedStub)
				})
			})
			r.Route("/config", func(r chi.Router) {
				r.With(requireUser).Get("/", svc.GetConfig)
			})
		})
	})

	return svc
}

// Ocs defines implements the business logic for Service.
type Ocs struct {
	config      *config.Config
	logger      log.Logger
	RoleService settingssvc.RoleService
	RoleManager *roles.Manager
	mux         *chi.Mux
}

// ServeHTTP implements the Service interface.
func (o Ocs) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	o.mux.ServeHTTP(w, r)
}

// NotFound uses ErrRender to always return a proper OCS payload
func (o Ocs) NotFound(w http.ResponseWriter, r *http.Request) {
	o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, "not found"))
}

func (o Ocs) getAccountService() accountssvc.AccountsService {
	return accountssvc.NewAccountsService("com.owncloud.api.accounts", grpc.DefaultClient)
}

func (o Ocs) getCS3Backend() backend.UserBackend {
	revaClient, err := pool.GetGatewayServiceClient(o.config.Reva.Address)
	if err != nil {
		o.logger.Fatal().Msgf("could not get reva client at address %s", o.config.Reva.Address)
	}
	return backend.NewCS3UserBackend(nil, revaClient, o.config.MachineAuthAPIKey, o.logger)
}

func (o Ocs) getGroupsService() accountssvc.GroupsService {
	return accountssvc.NewGroupsService("com.owncloud.api.accounts", grpc.DefaultClient)
}

// NotImplementedStub returns a not implemented error
func (o Ocs) NotImplementedStub(w http.ResponseWriter, r *http.Request) {
	o.mustRender(w, r, response.ErrRender(data.MetaUnknownError.StatusCode, "Not implemented"))
}

func (o Ocs) mustRender(w http.ResponseWriter, r *http.Request, renderer render.Renderer) {
	if err := render.Render(w, r, renderer); err != nil {
		o.logger.Err(err).Msgf("failed to write response for ocs request %s on %s", r.Method, r.URL)
	}
}
