package browser

import (
	"context"
	"fmt"
	"time"

	"github.com/chromedp/chromedp"
	"github.com/robke96/kioskipi/internal/config"
)

type BrowserManager struct {
	ctx        context.Context
	cancelFunc context.CancelFunc
}

var Manager *BrowserManager = &BrowserManager{}

func (bm *BrowserManager) Start() {
	configData := config.Get()

	// Chrome flags
	opts := append(chromedp.DefaultExecAllocatorOptions[:],
		chromedp.Flag("headless", true),
		chromedp.Flag("kiosk", true),
		chromedp.Flag("app", "about:blank"),
		chromedp.Flag("touch-events", true),
		chromedp.Flag("disable-gpu", true),
		chromedp.Flag("enable-low-end-device-mode", true),
		chromedp.Flag("no-sandbox", true),
		chromedp.Flag("no-zygote", true),
		chromedp.Flag("disable-popup-blocking", true),
		chromedp.Flag("disable-component-update", true),
		chromedp.Flag("enable-automation", false),
		chromedp.Flag("noerrdialogs", true),
	)

	allocatorCtx, _ := chromedp.NewExecAllocator(context.Background(), opts...)
	ctx, cancel := chromedp.NewContext(allocatorCtx)

	// Save context and cancel func
	bm.ctx = ctx
	bm.cancelFunc = cancel

	// Run tasks
	err := chromedp.Run(ctx,
		chromedp.Navigate(configData.Url),
		chromedp.WaitReady("body", chromedp.ByQuery),
	)

	if err != nil {
		fmt.Printf("Failed to start browser: %v\n", err)
		return
	}

	// hide cursor
	// TODO: make multi page support, reinject css on every page
	if configData.HideCursor {
		err = chromedp.Run(ctx,
			chromedp.WaitReady("body", chromedp.ByQuery),
			chromedp.MouseClickXY(1, 1),
			chromedp.Evaluate(`(() => {
				const style = document.createElement('style');
				style.innerHTML = '* { cursor: none !important; }';
				document.head.appendChild(style);
			})()`, nil),
		)
		if err != nil {
			fmt.Printf("Failed to hide cursor: %v\n", err)
		}
	}

	fmt.Println("browser started")
}

func (bm *BrowserManager) Restart() {
	fmt.Println("restarting browser")

	if bm.cancelFunc != nil {
		bm.cancelFunc()
		time.Sleep(1 * time.Second)
	}
	bm.Start()
}
