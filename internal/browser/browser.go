package browser

import (
	"fmt"

	"github.com/go-rod/rod"
	"github.com/go-rod/rod/lib/launcher"
	"github.com/robke96/kioskipi/internal/config"
)

type BrowserManager struct {
	Browser *rod.Browser
}

var Manager *BrowserManager = &BrowserManager{}

func (bm *BrowserManager) Start() {
	configData := config.Get()
	// url := "http://localhost:8080"

	systemBrowser, _ := launcher.LookPath()
	// "/usr/bin/chromium-browser"

	u := launcher.New().
		Bin(systemBrowser).
		Devtools(false).
		Headless(false).
		Delete("no-startup-window").
		Delete("no-first-run").
		Delete("enable-automation").
		Set("kiosk", "about:blank").
		MustLaunch()

	bm.Browser = rod.New()
	bm.Browser.ControlURL(u).MustConnect().NoDefaultDevice().MustPage(configData.Url).MustWaitLoad()

	// hide cursor
	if configData.HideCursor {
		bm.Browser.MustPages().First().MustEval(`() => {
			const style = document.createElement('style');
			style.textContent = '* { cursor: none !important; }';
			document.head.appendChild(style);
		}`)
	}

	fmt.Println("browser started")
}

func (bm *BrowserManager) Restart() {
	fmt.Println("restarting browser")

	if bm.Browser != nil {
		err := bm.Browser.Close()
		if err != nil {
			fmt.Printf("Error closing browser: %v\n", err)
		}
	}
	bm.Start()
}
