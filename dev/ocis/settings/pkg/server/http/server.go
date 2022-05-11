package http

import (
	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/owncloud/ocis/ocis-pkg/account"
	"github.com/owncloud/ocis/ocis-pkg/cors"
	"github.com/owncloud/ocis/ocis-pkg/middleware"
	"github.com/owncloud/ocis/ocis-pkg/service/http"
	"github.com/owncloud/ocis/ocis-pkg/version"
	settingssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/settings/v0"
	"github.com/owncloud/ocis/settings/pkg/assets"
	svc "github.com/owncloud/ocis/settings/pkg/service/v0"
	"go-micro.dev/v4"
)

// Server initializes the http service and server.
func Server(opts ...Option) http.Service {
	options := newOptions(opts...)

	service := http.NewService(
		http.Logger(options.Logger),
		http.Name(options.Name),
		http.Version(version.String),
		http.Address(options.Config.HTTP.Addr),
		http.Namespace(options.Config.HTTP.Namespace),
		http.Context(options.Context),
		http.Flags(options.Flags...),
	)

	handle := svc.NewService(options.Config, options.Logger)

	{
		handle = svc.NewInstrument(handle, options.Metrics)
		handle = svc.NewLogging(handle, options.Logger)
		handle = svc.NewTracing(handle)
	}

	mux := chi.NewMux()

	mux.Use(chimiddleware.RealIP)
	mux.Use(chimiddleware.RequestID)
	mux.Use(middleware.NoCache)
	mux.Use(middleware.Cors(
		cors.Logger(options.Logger),
		cors.AllowedOrigins(options.Config.HTTP.CORS.AllowedOrigins),
		cors.AllowedMethods(options.Config.HTTP.CORS.AllowedMethods),
		cors.AllowedHeaders(options.Config.HTTP.CORS.AllowedHeaders),
		cors.AllowCredentials(options.Config.HTTP.CORS.AllowCredentials),
	))
	mux.Use(middleware.Secure)
	mux.Use(middleware.ExtractAccountUUID(
		account.Logger(options.Logger),
		account.JWTSecret(options.Config.TokenManager.JWTSecret)),
	)

	mux.Use(middleware.Version(
		options.Name,
		version.String,
	))

	mux.Use(middleware.Logger(
		options.Logger,
	))

	mux.Use(middleware.Static(
		options.Config.HTTP.Root,
		assets.New(
			assets.Logger(options.Logger),
			assets.Config(options.Config),
		),
		options.Config.HTTP.CacheTTL,
	))

	mux.Route(options.Config.HTTP.Root, func(r chi.Router) {
		settingssvc.RegisterBundleServiceWeb(r, handle)
		settingssvc.RegisterValueServiceWeb(r, handle)
		settingssvc.RegisterRoleServiceWeb(r, handle)
		settingssvc.RegisterPermissionServiceWeb(r, handle)
	})

	micro.RegisterHandler(service.Server(), mux)

	return service
}
