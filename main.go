package main

import (
	"github.com/robke96/kioskipi/internal/browser"
	"github.com/robke96/kioskipi/internal/config"
	"github.com/robke96/kioskipi/internal/server"
)

func main() {
	if !config.Exists() {
		config.NewConfig()
	}

	browser.Manager.Start()
	server.Start()
}
