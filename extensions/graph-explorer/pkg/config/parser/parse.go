package parser

import (
	"errors"

	"github.com/owncloud/ocis/v2/extensions/graph-explorer/pkg/config"
	"github.com/owncloud/ocis/v2/extensions/graph-explorer/pkg/config/defaults"
	ociscfg "github.com/owncloud/ocis/v2/ocis-pkg/config"

	"github.com/owncloud/ocis/v2/ocis-pkg/config/envdecode"
)

// ParseConfig loads configuration from known paths.
func ParseConfig(cfg *config.Config) error {
	_, err := ociscfg.BindSourcesToStructs(cfg.Service.Name, cfg)
	if err != nil {
		return err
	}

	defaults.EnsureDefaults(cfg)

	// load all env variables relevant to the config in the current context.
	if err := envdecode.Decode(cfg); err != nil {
		// no environment variable set for this config is an expected "error"
		if !errors.Is(err, envdecode.ErrNoTargetFieldsAreSet) {
			return err
		}
	}

	// sanitize config
	defaults.Sanitize(cfg)

	return Validate(cfg)
}

func Validate(cfg *config.Config) error {
	return nil
}
