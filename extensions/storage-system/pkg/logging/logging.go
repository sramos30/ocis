package logging

import (
	"github.com/owncloud/ocis/v2/extensions/storage-system/pkg/config"
	"github.com/owncloud/ocis/v2/ocis-pkg/log"
)

// LoggerFromConfig initializes a service-specific logger instance.
func Configure(name string, cfg *config.Log) log.Logger {
	return log.NewLogger(
		log.Name(name),
		log.Level(cfg.Level),
		log.Pretty(cfg.Pretty),
		log.Color(cfg.Color),
		log.File(cfg.File),
	)
}
