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
	port := 54321

	http.Handle("/", templ.Handler(Home()))
	http.HandleFunc("/save", saveConfigHandler)

	fmt.Println("Starting server at port ", port)
	addr := ":" + strconv.Itoa(port)
	http.ListenAndServe(addr, nil)
}

func saveConfigHandler(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()

	cfg := config.Config{
		Url:        r.FormValue("url"),
		HideCursor: r.FormValue("hidecursor") == "on",
	}

	config.Save(&cfg)
	browser.Manager.Restart()
	http.Redirect(w, r, "/", http.StatusSeeOther)
}
