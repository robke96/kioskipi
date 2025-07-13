package server

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
)

func Start() {
	port := 8080

	staticFiles := http.FileServer(http.Dir("../../web"))
	http.Handle("/", staticFiles)

	fmt.Println("Starting server at port ", port)
	addr := ":" + strconv.Itoa(port)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatal(err)
	}
}
