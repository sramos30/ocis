package command

import (
	"context"
	"fmt"
	"os"

	"github.com/oklog/run"

	"github.com/owncloud/ocis/v2/extensions/store/pkg/config"
	"github.com/owncloud/ocis/v2/extensions/store/pkg/config/parser"
	"github.com/owncloud/ocis/v2/extensions/store/pkg/logging"
	"github.com/owncloud/ocis/v2/extensions/store/pkg/metrics"
	"github.com/owncloud/ocis/v2/extensions/store/pkg/server/debug"
	"github.com/owncloud/ocis/v2/extensions/store/pkg/server/grpc"
	"github.com/owncloud/ocis/v2/extensions/store/pkg/tracing"
	"github.com/owncloud/ocis/v2/ocis-pkg/version"
	"github.com/urfave/cli/v2"
)

// Server is the entrypoint for the server command.
func Server(cfg *config.Config) *cli.Command {
	return &cli.Command{
		Name:     "server",
		Usage:    fmt.Sprintf("start %s extension without runtime (unsupervised mode)", cfg.Service.Name),
		Category: "server",
		Before: func(c *cli.Context) error {
			err := parser.ParseConfig(cfg)
			if err != nil {
				fmt.Printf("%v", err)
				os.Exit(1)
			}
			return err
		},
		Action: func(c *cli.Context) error {
			logger := logging.Configure(cfg.Service.Name, cfg.Log)
			err := tracing.Configure(cfg)
			if err != nil {
				return err
			}

			var (
				gr          = run.Group{}
				ctx, cancel = func() (context.Context, context.CancelFunc) {
					if cfg.Context == nil {
						return context.WithCancel(context.Background())
					}
					return context.WithCancel(cfg.Context)
				}()
				metrics = metrics.New()
			)

			defer cancel()

			metrics.BuildInfo.WithLabelValues(version.String).Set(1)

			{
				server := grpc.Server(
					grpc.Logger(logger),
					grpc.Context(ctx),
					grpc.Config(cfg),
					grpc.Metrics(metrics),
				)

				gr.Add(server.Run, func(_ error) {
					logger.Info().
						Str("server", "grpc").
						Msg("Shutting down server")

					cancel()
				})
			}

			{
				server, err := debug.Server(
					debug.Logger(logger),
					debug.Context(ctx),
					debug.Config(cfg),
				)

				if err != nil {
					logger.Error().Err(err).Str("server", "debug").Msg("Failed to initialize server")
					return err
				}

				gr.Add(server.ListenAndServe, func(_ error) {
					_ = server.Shutdown(ctx)
					cancel()
				})
			}

			return gr.Run()
		},
	}
}
