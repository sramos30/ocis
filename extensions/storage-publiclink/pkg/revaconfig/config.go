package revaconfig

import (
	"github.com/owncloud/ocis/v2/extensions/storage-publiclink/pkg/config"
)

// StoragePublicLinkConfigFromStruct will adapt an oCIS config struct into a reva mapstructure to start a reva service.
func StoragePublicLinkConfigFromStruct(cfg *config.Config) map[string]interface{} {
	rcfg := map[string]interface{}{
		"core": map[string]interface{}{
			"tracing_enabled":      cfg.Tracing.Enabled,
			"tracing_endpoint":     cfg.Tracing.Endpoint,
			"tracing_collector":    cfg.Tracing.Collector,
			"tracing_service_name": cfg.Service.Name,
		},
		"shared": map[string]interface{}{
			"jwt_secret":                cfg.TokenManager.JWTSecret,
			"gatewaysvc":                cfg.Reva.Address,
			"skip_user_groups_in_token": cfg.SkipUserGroupsInToken,
		},
		"grpc": map[string]interface{}{
			"network": cfg.GRPC.Protocol,
			"address": cfg.GRPC.Addr,
			"interceptors": map[string]interface{}{
				"log": map[string]interface{}{},
			},
			"services": map[string]interface{}{
				"publicstorageprovider": map[string]interface{}{
					"mount_id":     cfg.StorageProvider.MountID,
					"gateway_addr": cfg.Reva.Address,
				},
				"authprovider": map[string]interface{}{
					"auth_manager": "publicshares",
					"auth_managers": map[string]interface{}{
						"publicshares": map[string]interface{}{
							"gateway_addr": cfg.Reva.Address,
						},
					},
				},
			},
		},
	}
	return rcfg
}
