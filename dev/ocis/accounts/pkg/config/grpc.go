package config

// GRPC defines the available grpc configuration.
type GRPC struct {
	Addr      string `yaml:"addr" env:"ACCOUNTS_GRPC_ADDR" desc:"The address of the grpc service."`
	Namespace string `yaml:"-"`
}
