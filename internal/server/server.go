package server

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/a-h/templ"
	"github.com/robke96/kioskipi/internal/browser"
	"github.com/robke96/kioskipi/internal/config"
)

func Start() {
	port := config.Get().Port

	http.Handle("/", templ.Handler(Home()))
	http.HandleFunc("/save", saveConfigHandler)

	fmt.Println("Starting server at port ", port)
	addr := ":" + strconv.Itoa(int(port))
	http.ListenAndServe(addr, nil)
}

func saveConfigHandler(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()

	rawPort := r.FormValue("port")
	port, err := strconv.ParseUint(rawPort, 10, 16)
	if err != nil {
		templ.Raw(`<div style="color:red;">Invalid port number</div>`).Render(r.Context(), w)
		return
	}

	newPort := uint16(port)
	oldConfig := config.Get()

	cfg := config.Config{
		Url:        r.FormValue("url"),
		HideCursor: r.FormValue("hidecursor") == "on",
		Port:       newPort,
	}

	config.Save(&cfg)

	var msg string

	if oldConfig.Port != newPort {
		msg = `<div style="color:orange;">Saved. Restart your system required!</div>`
	} else {
		msg = `<div style="color:green;">Saved successfully.</div>`
	}

	browser.Manager.Restart()
	// http.Redirect(w, r, "/", http.StatusSeeOther)
	w.Header().Set("Content-Type", "text/html")
	templ.Raw(msg).Render(r.Context(), w)
}
