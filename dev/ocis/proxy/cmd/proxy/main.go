package main

import (
	"os"

	"github.com/owncloud/ocis/proxy/pkg/command"
	"github.com/owncloud/ocis/proxy/pkg/config/defaults"
)

func main() {
	if err := command.Execute(defaults.DefaultConfig()); err != nil {
		os.Exit(1)
	}
}
