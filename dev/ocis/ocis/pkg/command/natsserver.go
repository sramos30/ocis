package command

import (
	"github.com/owncloud/ocis/nats/pkg/command"
	"github.com/owncloud/ocis/ocis-pkg/config"
	"github.com/owncloud/ocis/ocis-pkg/config/parser"
	"github.com/owncloud/ocis/ocis/pkg/register"
	"github.com/urfave/cli/v2"
)

// NatsServerCommand is the entrypoint for the nats server command.
func NatsServerCommand(cfg *config.Config) *cli.Command {
	return &cli.Command{
		Name:     "nats-server",
		Usage:    "start nats server",
		Category: "extensions",
		Before: func(ctx *cli.Context) error {
			return parser.ParseConfig(cfg)
		},
		Subcommands: command.GetCommands(cfg.Nats),
	}
}

func init() {
	register.AddCommand(NatsServerCommand)
}
