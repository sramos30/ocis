package command

import (
	"context"
	"fmt"

	"github.com/oklog/run"
	"github.com/owncloud/ocis/ocis-pkg/version"
	"github.com/owncloud/ocis/settings/pkg/config"
	"github.com/owncloud/ocis/settings/pkg/config/parser"
	"github.com/owncloud/ocis/settings/pkg/logging"
	"github.com/owncloud/ocis/settings/pkg/metrics"
	"github.com/owncloud/ocis/settings/pkg/server/debug"
	"github.com/owncloud/ocis/settings/pkg/server/grpc"
	"github.com/owncloud/ocis/settings/pkg/server/http"
	"github.com/owncloud/ocis/settings/pkg/tracing"
	"github.com/urfave/cli/v2"
)

// Server is the entrypoint for the server command.
func Server(cfg *config.Config) *cli.Command {
	return &cli.Command{
		Name:     "server",
		Usage:    fmt.Sprintf("start %s extension without runtime (unsupervised mode)", cfg.Service.Name),
		Category: "server",
		Before: func(c *cli.Context) error {
			return parser.ParseConfig(cfg)
		},
		Action: func(c *cli.Context) error {
			logger := logging.Configure(cfg.Service.Name, cfg.Log)
			err := tracing.Configure(cfg)
			if err != nil {
				return err
			}

			servers := run.Group{}
			ctx, cancel := func() (context.Context, context.CancelFunc) {
				if cfg.Context == nil {
					return context.WithCancel(context.Background())
				}
				return context.WithCancel(cfg.Context)
			}()
			defer cancel()

			mtrcs := metrics.New()
			mtrcs.BuildInfo.WithLabelValues(version.String).Set(1)

			// prepare an HTTP server and add it to the group run.
			httpServer := http.Server(
				http.Name(cfg.Service.Name),
				http.Logger(logger),
				http.Context(ctx),
				http.Config(cfg),
				http.Metrics(mtrcs),
			)
			servers.Add(httpServer.Run, func(_ error) {
				logger.Info().Str("server", "http").Msg("Shutting down server")
				cancel()
			})

			// prepare a gRPC server and add it to the group run.
			grpcServer := grpc.Server(grpc.Name(cfg.Service.Name), grpc.Logger(logger), grpc.Context(ctx), grpc.Config(cfg), grpc.Metrics(mtrcs))
			servers.Add(grpcServer.Run, func(_ error) {
				logger.Info().Str("server", "grpc").Msg("Shutting down server")
				cancel()
			})

			// prepare a debug server and add it to the group run.
			debugServer, err := debug.Server(debug.Logger(logger), debug.Context(ctx), debug.Config(cfg))
			if err != nil {
				logger.Error().Err(err).Str("server", "debug").Msg("Failed to initialize server")
				return err
			}

			servers.Add(debugServer.ListenAndServe, func(_ error) {
				_ = debugServer.Shutdown(ctx)
				cancel()
			})

			return servers.Run()
		},
	}
}
