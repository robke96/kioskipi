package main

import (
	"github.com/robke96/kioskipi/internal/browser"
	"github.com/robke96/kioskipi/internal/config"
	"github.com/robke96/kioskipi/internal/server"
)

func main() {
	if !config.Exists() {
		data := &config.Config{
			Url:  "http://example.com",
			Port: 54321,
		}

		config.NewConfig(data)
	}

	browser.Manager.Start()
	server.Start()
}
