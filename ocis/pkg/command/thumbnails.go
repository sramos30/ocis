package command

import (
	"fmt"

	"github.com/owncloud/ocis/v2/extensions/thumbnails/pkg/command"
	"github.com/owncloud/ocis/v2/ocis-pkg/config"
	"github.com/owncloud/ocis/v2/ocis-pkg/config/parser"
	"github.com/owncloud/ocis/v2/ocis/pkg/register"
	"github.com/urfave/cli/v2"
)

// ThumbnailsCommand is the entrypoint for the thumbnails command.
func ThumbnailsCommand(cfg *config.Config) *cli.Command {
	return &cli.Command{
		Name:     cfg.Thumbnails.Service.Name,
		Usage:    subcommandDescription(cfg.Thumbnails.Service.Name),
		Category: "extensions",
		Before: func(c *cli.Context) error {
			if err := parser.ParseConfig(cfg); err != nil {
				fmt.Printf("%v", err)
				return err
			}
			cfg.Thumbnails.Commons = cfg.Commons
			return nil
		},
		Subcommands: command.GetCommands(cfg.Thumbnails),
	}
}

func init() {
	register.AddCommand(ThumbnailsCommand)
}
