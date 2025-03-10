package command

import (
	"fmt"
	"net/http"

	"github.com/owncloud/ocis/v2/extensions/accounts/pkg/config"
	"github.com/owncloud/ocis/v2/extensions/accounts/pkg/config/parser"
	"github.com/owncloud/ocis/v2/extensions/accounts/pkg/logging"
	"github.com/urfave/cli/v2"
)

// Health is the entrypoint for the health command.
func Health(cfg *config.Config) *cli.Command {
	return &cli.Command{
		Name:     "health",
		Usage:    "check health status",
		Category: "info",
		Before: func(c *cli.Context) error {
			err := parser.ParseConfig(cfg)
			if err != nil {
				fmt.Printf("%v", err)
			}
			return err
		},
		Action: func(c *cli.Context) error {
			logger := logging.Configure(cfg.Service.Name, cfg.Log)

			resp, err := http.Get(
				fmt.Sprintf(
					"http://%s/healthz",
					cfg.Debug.Addr,
				),
			)

			if err != nil {
				logger.Fatal().
					Err(err).
					Msg("Failed to request health check")
			}

			defer resp.Body.Close()

			if resp.StatusCode != http.StatusOK {
				logger.Fatal().
					Int("code", resp.StatusCode).
					Msg("Health seems to be in bad state")
			}

			logger.Debug().
				Int("code", resp.StatusCode).
				Msg("Health got a good state")

			return nil
		},
	}
}
