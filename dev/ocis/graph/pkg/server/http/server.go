package http

import (
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	graphMiddleware "github.com/owncloud/ocis/graph/pkg/middleware"
	svc "github.com/owncloud/ocis/graph/pkg/service/v0"
	"github.com/owncloud/ocis/ocis-pkg/account"
	"github.com/owncloud/ocis/ocis-pkg/middleware"
	"github.com/owncloud/ocis/ocis-pkg/service/http"
	"github.com/owncloud/ocis/ocis-pkg/version"
	"go-micro.dev/v4"
)

// Server initializes the http service and server.
func Server(opts ...Option) (http.Service, error) {
	options := newOptions(opts...)

	service := http.NewService(
		http.Logger(options.Logger),
		http.Namespace(options.Config.HTTP.Namespace),
		http.Name("graph"),
		http.Version(version.String),
		http.Address(options.Config.HTTP.Addr),
		http.Context(options.Context),
		http.Flags(options.Flags...),
	)

	handle := svc.NewService(
		svc.Logger(options.Logger),
		svc.Config(options.Config),
		svc.Middleware(
			chimiddleware.RequestID,
			middleware.Version(
				"graph",
				version.String,
			),
			middleware.Logger(
				options.Logger,
			),
			graphMiddleware.Auth(
				account.Logger(options.Logger),
				account.JWTSecret(options.Config.TokenManager.JWTSecret),
			),
		),
	)

	{
		handle = svc.NewInstrument(handle, options.Metrics)
		handle = svc.NewLogging(handle, options.Logger)
		handle = svc.NewTracing(handle)
	}

	if err := micro.RegisterHandler(service.Server(), handle); err != nil {
		return http.Service{}, err
	}

	return service, nil
}
