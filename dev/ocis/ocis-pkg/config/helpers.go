package config

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	gofig "github.com/gookit/config/v2"
	gooyaml "github.com/gookit/config/v2/yaml"
)

var (
	defaultLocations = []string{
		filepath.Join(os.Getenv("HOME"), "/.ocis/config/"),
		"/etc/ocis/",
		".config/",
	}

	// supportedExtensions is determined by gookit/config.
	supportedExtensions = []string{
		"yaml",
		"yml",
	}
)

// DefaultConfigSources returns a slice with matched expected config files. It sugars coat several aspects of config file
// management by assuming there are 3 default locations a config file could be.
// It uses globbing to match a config file by name, and retrieve any supported extension supported by our drivers.
// It sanitizes the output depending on the list of drivers provided.
func DefaultConfigSources(filename string, drivers []string) []string {
	var sources []string

	locations := []string{}
	if v := os.Getenv("OCIS_CONFIG_DIR"); v != "" {
	    locations = append(locations, v)
		// only use the configured config dir
		locations = append(locations, os.Getenv("OCIS_CONFIG_DIR"))
	} else {
		// merge config from all default locations
		locations = append(locations, defaultLocations...)
	}

	for i := range locations {
		dirFS := os.DirFS(locations[i])
		pattern := filename + ".*"
		matched, _ := fs.Glob(dirFS, pattern)
		if len(matched) > 0 {
			// prepend path to results
			for j := 0; j < len(matched); j++ {
				matched[j] = filepath.Join(locations[i], matched[j])
			}
		}
		sources = append(sources, matched...)
	}

	return sanitizeExtensions(sources, drivers, func(a, b string) bool {
		return strings.HasSuffix(filepath.Base(a), b)
	})
}

// sanitizeExtensions removes elements from "set" which extensions are not in "ext".
func sanitizeExtensions(set []string, ext []string, f func(a, b string) bool) []string {
	var r []string
	for i := 0; i < len(set); i++ {
		for j := 0; j < len(ext); j++ {
			if f(filepath.Base(set[i]), ext[j]) {
				r = append(r, set[i])
			}
		}
	}
	return r
}

// BindSourcesToStructs assigns any config value from a config file / env variable to struct `dst`. Its only purpose
// is to solely modify `dst`, not dealing with the config structs; and do so in a thread safe manner.
func BindSourcesToStructs(extension string, dst interface{}) (*gofig.Config, error) {
	sources := DefaultConfigSources(extension, supportedExtensions)
	cnf := gofig.NewWithOptions(extension)
	cnf.WithOptions(func(options *gofig.Options) {
		options.DecoderConfig.TagName = "yaml"
	})
	cnf.AddDriver(gooyaml.Driver)
	_ = cnf.LoadFiles(sources...)

	err := cnf.BindStruct("", &dst)
	if err != nil {
		return nil, err
	}

	return cnf, nil
}
