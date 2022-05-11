package config

import (
	"context"

	"github.com/owncloud/ocis/ocis-pkg/shared"
)

// Config combines all available configuration parts.
type Config struct {
	*shared.Commons `yaml:"-"`

	Service Service `yaml:"-"`

	Tracing *Tracing `yaml:"tracing"`
	Log     *Log     `yaml:"log"`
	Debug   Debug    `yaml:"debug"`

	HTTP HTTP `yaml:"http"`

	GraphExplorer GraphExplorer `yaml:"graph_explorer"`

	Context context.Context `yaml:"-"`
}

// GraphExplorer defines the available graph-explorer configuration.
type GraphExplorer struct {
	ClientID     string `yaml:"client_id" env:"GRAPH_EXPLORER_CLIENT_ID"`
	Issuer       string `yaml:"issuer" env:"OCIS_URL;GRAPH_EXPLORER_ISSUER"`
	GraphURLBase string `yaml:"graph_url_base" env:"OCIS_URL;GRAPH_EXPLORER_GRAPH_URL_BASE"`
	GraphURLPath string `yaml:"graph_url_path" env:"GRAPH_EXPLORER_GRAPH_URL_PATH"`
}
