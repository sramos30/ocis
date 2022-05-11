package command

import (
	"github.com/owncloud/ocis/ocis-pkg/config"
	"github.com/owncloud/ocis/ocis/pkg/register"
	"github.com/owncloud/ocis/storage/pkg/command"
	"github.com/urfave/cli/v2"
)

// StorageFrontendCommand is the entrypoint for the reva-frontend command.
func StorageFrontendCommand(cfg *config.Config) *cli.Command {
	return &cli.Command{
		Name:     "storage-frontend",
		Usage:    "start storage frontend",
		Category: "extensions",
		//Flags:    flagset.FrontendWithConfig(cfg.Storage),
		Before: func(ctx *cli.Context) error {
			return ParseStorageCommon(ctx, cfg)
		},
		Action: func(c *cli.Context) error {
			origCmd := command.Frontend(cfg.Storage)
			return handleOriginalAction(c, origCmd)
		},
	}
}

func init() {
	register.AddCommand(StorageFrontendCommand)
}
