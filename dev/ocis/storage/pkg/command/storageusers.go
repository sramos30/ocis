package command

import (
	"context"
	"flag"
	"os"
	"path"

	"github.com/cs3org/reva/v2/cmd/revad/runtime"
	"github.com/gofrs/uuid"
	"github.com/oklog/run"
	ociscfg "github.com/owncloud/ocis/ocis-pkg/config"
	"github.com/owncloud/ocis/ocis-pkg/sync"
	"github.com/owncloud/ocis/storage/pkg/command/storagedrivers"
	"github.com/owncloud/ocis/storage/pkg/config"
	"github.com/owncloud/ocis/storage/pkg/server/debug"
	"github.com/owncloud/ocis/storage/pkg/tracing"
	"github.com/thejerf/suture/v4"
	"github.com/urfave/cli/v2"
)

// StorageUsers is the entrypoint for the storage-users command.
func StorageUsers(cfg *config.Config) *cli.Command {
	return &cli.Command{
		Name:  "storage-users",
		Usage: "start storage-users service",
		Before: func(c *cli.Context) error {
			return ParseConfig(c, cfg, "storage-userprovider")
		},
		Action: func(c *cli.Context) error {
			logger := NewLogger(cfg)

			tracing.Configure(cfg, logger)

			gr := run.Group{}
			ctx, cancel := context.WithCancel(context.Background())

			defer cancel()

			uuid := uuid.Must(uuid.NewV4())
			pidFile := path.Join(os.TempDir(), "revad-"+c.Command.Name+"-"+uuid.String()+".pid")

			rcfg := storageUsersConfigFromStruct(c, cfg)

			gr.Add(func() error {
				runtime.RunWithOptions(
					rcfg,
					pidFile,
					runtime.WithLogger(&logger.Logger),
				)
				return nil
			}, func(_ error) {
				logger.Info().
					Str("server", c.Command.Name).
					Msg("Shutting down server")

				cancel()
			})

			debugServer, err := debug.Server(
				debug.Name(c.Command.Name+"-debug"),
				debug.Addr(cfg.Reva.StorageUsers.DebugAddr),
				debug.Logger(logger),
				debug.Context(ctx),
				debug.Config(cfg),
			)

			if err != nil {
				logger.Info().Err(err).Str("server", c.Command.Name+"-debug").Msg("Failed to initialize server")
				return err
			}

			gr.Add(debugServer.ListenAndServe, func(_ error) {
				cancel()
			})

			if !cfg.Reva.StorageUsers.Supervised {
				sync.Trap(&gr, cancel)
			}

			return gr.Run()
		},
	}
}

// storageUsersConfigFromStruct will adapt an oCIS config struct into a reva mapstructure to start a reva service.
func storageUsersConfigFromStruct(c *cli.Context, cfg *config.Config) map[string]interface{} {
	rcfg := map[string]interface{}{
		"core": map[string]interface{}{
			"max_cpus":             cfg.Reva.StorageUsers.MaxCPUs,
			"tracing_enabled":      cfg.Tracing.Enabled,
			"tracing_endpoint":     cfg.Tracing.Endpoint,
			"tracing_collector":    cfg.Tracing.Collector,
			"tracing_service_name": c.Command.Name,
		},
		"shared": map[string]interface{}{
			"jwt_secret":                cfg.Reva.JWTSecret,
			"gatewaysvc":                cfg.Reva.Gateway.Endpoint,
			"skip_user_groups_in_token": cfg.Reva.SkipUserGroupsInToken,
		},
		"grpc": map[string]interface{}{
			"network": cfg.Reva.StorageUsers.GRPCNetwork,
			"address": cfg.Reva.StorageUsers.GRPCAddr,
			// TODO build services dynamically
			"services": map[string]interface{}{
				"storageprovider": map[string]interface{}{
					"driver":             cfg.Reva.StorageUsers.Driver,
					"drivers":            storagedrivers.UserDrivers(cfg),
					"mount_id":           cfg.Reva.StorageUsers.MountID,
					"expose_data_server": cfg.Reva.StorageUsers.ExposeDataServer,
					"data_server_url":    cfg.Reva.StorageUsers.DataServerURL,
					"tmp_folder":         cfg.Reva.StorageUsers.TempFolder,
				},
			},
			"interceptors": map[string]interface{}{
				"eventsmiddleware": map[string]interface{}{
					"group":     "sharing",
					"type":      "nats",
					"address":   cfg.Reva.Sharing.Events.Address,
					"clusterID": cfg.Reva.Sharing.Events.ClusterID,
				},
			},
		},
		"http": map[string]interface{}{
			"network": cfg.Reva.StorageUsers.HTTPNetwork,
			"address": cfg.Reva.StorageUsers.HTTPAddr,
			// TODO build services dynamically
			"services": map[string]interface{}{
				"dataprovider": map[string]interface{}{
					"prefix":      cfg.Reva.StorageUsers.HTTPPrefix,
					"driver":      cfg.Reva.StorageUsers.Driver,
					"drivers":     storagedrivers.UserDrivers(cfg),
					"timeout":     86400,
					"insecure":    cfg.Reva.StorageUsers.DataProvider.Insecure,
					"disable_tus": false,
				},
			},
		},
	}
	if cfg.Reva.StorageUsers.ReadOnly {
		gcfg := rcfg["grpc"].(map[string]interface{})
		gcfg["interceptors"] = map[string]interface{}{
			"readonly": map[string]interface{}{},
		}
	}
	return rcfg
}

// StorageUsersSutureService allows for the storage-home command to be embedded and supervised by a suture supervisor tree.
type StorageUsersSutureService struct {
	cfg *config.Config
}

// NewStorageUsersSutureService creates a new storage.StorageUsersSutureService
func NewStorageUsers(cfg *ociscfg.Config) suture.Service {
	cfg.Storage.Commons = cfg.Commons
	return StorageUsersSutureService{
		cfg: cfg.Storage,
	}
}

func (s StorageUsersSutureService) Serve(ctx context.Context) error {
	s.cfg.Reva.StorageUsers.Context = ctx
	f := &flag.FlagSet{}
	cmdFlags := StorageUsers(s.cfg).Flags
	for k := range cmdFlags {
		if err := cmdFlags[k].Apply(f); err != nil {
			return err
		}
	}
	cliCtx := cli.NewContext(nil, f, nil)
	if StorageUsers(s.cfg).Before != nil {
		if err := StorageUsers(s.cfg).Before(cliCtx); err != nil {
			return err
		}
	}
	if err := StorageUsers(s.cfg).Action(cliCtx); err != nil {
		return err
	}

	return nil
}
