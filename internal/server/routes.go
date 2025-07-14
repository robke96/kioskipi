package server

import (
	"fmt"
	"net/http"
	"strconv"
	"text/template"

	_ "embed"

	"github.com/robke96/kioskipi/internal/config"
)

//go:embed web/index.html
var indexHTML string

func homePage(w http.ResponseWriter, r *http.Request) {
	cfg := config.Get()

	tmpl := template.Must(template.New("config").Parse(indexHTML))
	tmpl.Execute(w, cfg)
}

func Start() {
	port := 8080

	http.HandleFunc("/", homePage)
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
	http.Redirect(w, r, "/", http.StatusSeeOther)
}
