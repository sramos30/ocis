package tracing

import (
	pkgtrace "github.com/owncloud/ocis/ocis-pkg/tracing"
	"github.com/owncloud/ocis/settings/pkg/config"
	"go.opentelemetry.io/otel/trace"
)

var (
	// TraceProvider is the global trace provider for the settings service.
	TraceProvider = trace.NewNoopTracerProvider()
)

func Configure(cfg *config.Config) error {
	var err error
	if cfg.Tracing.Enabled {
		if TraceProvider, err = pkgtrace.GetTraceProvider(cfg.Tracing.Endpoint, cfg.Tracing.Collector, cfg.Service.Name, cfg.Tracing.Type); err != nil {
			return err
		}
	}

	return nil
}
