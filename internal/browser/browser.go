package browser

import (
	"fmt"

	"github.com/go-rod/rod"
	"github.com/go-rod/rod/lib/launcher"
	"github.com/robke96/kioskipi/internal/config"
)

func Start() {
	url := config.Get().Url
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

	page := rod.New().ControlURL(u).MustConnect().NoDefaultDevice().MustPage(url)
	page.MustWaitLoad()
	fmt.Println("browser started")
}
