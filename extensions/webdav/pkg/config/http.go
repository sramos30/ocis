package config

// CORS defines the available cors configuration.
type CORS struct {
	AllowedOrigins   []string `yaml:"allowed_origins"`
	AllowedMethods   []string `yaml:"allowed_methods"`
	AllowedHeaders   []string `yaml:"allowed_headers"`
	AllowCredentials bool     `yaml:"allow_credentials"`
}

// HTTP defines the available http configuration.
type HTTP struct {
	Addr      string `yaml:"addr" env:"WEBDAV_HTTP_ADDR" desc:"The HTTP API address."`
	Namespace string `yaml:"-"`
	Root      string `yaml:"root" env:"WEBDAV_HTTP_ROOT" desc:"The HTTP API root path."`
	CORS      CORS   `yaml:"cors"`
}
