package http

import (
	accountssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/accounts/v0"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/owncloud/ocis/accounts/pkg/assets"
	"github.com/owncloud/ocis/ocis-pkg/account"
	"github.com/owncloud/ocis/ocis-pkg/cors"
	"github.com/owncloud/ocis/ocis-pkg/middleware"
	"github.com/owncloud/ocis/ocis-pkg/service/http"
	"github.com/owncloud/ocis/ocis-pkg/version"
	"go-micro.dev/v4"
)

// Server initializes the http service and server.
func Server(opts ...Option) http.Service {
	options := newOptions(opts...)
	handler := options.Handler

	service := http.NewService(
		http.Logger(options.Logger),
		http.Name(options.Name),
		http.Version(version.String),
		http.Address(options.Config.HTTP.Addr),
		http.Namespace(options.Config.HTTP.Namespace),
		http.Context(options.Context),
		http.Flags(options.Flags...),
	)

	mux := chi.NewMux()

	mux.Use(chimiddleware.RealIP)
	mux.Use(chimiddleware.RequestID)
	mux.Use(middleware.TraceContext)
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
		accountssvc.RegisterAccountsServiceWeb(r, handler)
		accountssvc.RegisterGroupsServiceWeb(r, handler)
	})

	err := micro.RegisterHandler(service.Server(), mux)
	if err != nil {
		options.Logger.Fatal().Err(err).Msg("failed to register the handler")
	}

	return service
}
