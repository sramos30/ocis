package external

import (
	"context"
	"time"

	"github.com/owncloud/ocis/v2/ocis-pkg/log"
	oregistry "github.com/owncloud/ocis/v2/ocis-pkg/registry"
	"go-micro.dev/v4/broker"
	"go-micro.dev/v4/registry"
)

// RegisterGRPCEndpoint publishes an arbitrary endpoint to the service-registry. This allows to query nodes of
// non-micro GRPC-services like reva. No health-checks are done, thus the caller is responsible for canceling.
func RegisterGRPCEndpoint(ctx context.Context, serviceID, uuid, addr string, version string, logger log.Logger) error {
	node := &registry.Node{
		Id:       serviceID + "-" + uuid,
		Address:  addr,
		Metadata: make(map[string]string),
	}
	ocisRegistry := oregistry.GetRegistry()

	node.Metadata["broker"] = broker.String()
	node.Metadata["registry"] = ocisRegistry.String()
	node.Metadata["server"] = "grpc"
	node.Metadata["transport"] = "grpc"
	node.Metadata["protocol"] = "grpc"

	service := &registry.Service{
		Name:      serviceID,
		Version:   version,
		Nodes:     []*registry.Node{node},
		Endpoints: make([]*registry.Endpoint, 0),
	}

	logger.Info().Msgf("registering external service %v@%v", node.Id, node.Address)

	rOpts := []registry.RegisterOption{registry.RegisterTTL(time.Minute)}
	if err := ocisRegistry.Register(service, rOpts...); err != nil {
		logger.Fatal().Err(err).Msgf("Registration error for external service %v", serviceID)
	}

	t := time.NewTicker(time.Second * 30)

	go func() {
		for {
			select {
			case <-t.C:
				logger.Debug().Interface("service", service).Msg("refreshing external service-registration")
				err := ocisRegistry.Register(service, rOpts...)
				if err != nil {
					logger.Error().Err(err).Msgf("registration error for external service %v", serviceID)
				}
			case <-ctx.Done():
				logger.Debug().Interface("service", service).Msg("unregistering")
				t.Stop()
				err := ocisRegistry.Deregister(service)
				if err != nil {
					logger.Err(err).Msgf("Error unregistering external service %v", serviceID)
				}

			}
		}
	}()

	return nil
}

// RegisterHTTPEndpoint publishes an arbitrary endpoint to the service-registry. This allows to query nodes of
// non-micro HTTP-services like reva. No health-checks are done, thus the caller is responsible for canceling.
func RegisterHTTPEndpoint(ctx context.Context, serviceID, uuid, addr string, version string, logger log.Logger) error {
	node := &registry.Node{
		Id:       serviceID + "-" + uuid,
		Address:  addr,
		Metadata: make(map[string]string),
	}
	ocisRegistry := oregistry.GetRegistry()

	node.Metadata["broker"] = broker.String()
	node.Metadata["registry"] = ocisRegistry.String()
	node.Metadata["server"] = "http"
	node.Metadata["transport"] = "http"
	node.Metadata["protocol"] = "http"

	service := &registry.Service{
		Name:      serviceID,
		Version:   version,
		Nodes:     []*registry.Node{node},
		Endpoints: make([]*registry.Endpoint, 0),
	}

	logger.Info().Msgf("registering external service %v@%v", node.Id, node.Address)

	rOpts := []registry.RegisterOption{registry.RegisterTTL(time.Minute)}
	if err := ocisRegistry.Register(service, rOpts...); err != nil {
		logger.Fatal().Err(err).Msgf("Registration error for external service %v", serviceID)
	}

	t := time.NewTicker(time.Second * 30)

	go func() {
		for {
			select {
			case <-t.C:
				logger.Debug().Interface("service", service).Msg("refreshing external service-registration")
				err := ocisRegistry.Register(service, rOpts...)
				if err != nil {
					logger.Error().Err(err).Msgf("registration error for external service %v", serviceID)
				}
			case <-ctx.Done():
				logger.Debug().Interface("service", service).Msg("unregistering")
				t.Stop()
				err := ocisRegistry.Deregister(service)
				if err != nil {
					logger.Err(err).Msgf("Error unregistering external service %v", serviceID)
				}

			}
		}
	}()

	return nil
}
