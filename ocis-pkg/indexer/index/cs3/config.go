package cs3

import (
	acccfg "github.com/owncloud/ocis/v2/extensions/accounts/pkg/config"
)

// Config represents cs3conf. Should be deprecated in favor of config.Config.
type Config struct {
	ProviderAddr string
	JWTSecret    string
	ServiceUser  acccfg.ServiceUser
}
