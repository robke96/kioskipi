package main

import (
	"github.com/robke96/kioskipi/internal/config"
	"github.com/robke96/kioskipi/internal/server"
)

func main() {
	if !config.Exists() {
		config.NewConfig()
	}

	// go browser.Start()
	server.Start()
}
