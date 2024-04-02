package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"
)

func handler(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")
	if name == "" {
		name = "Guest"
	}
	response := fmt.Sprintf("Hello, %s!", strings.Title(name))
	fmt.Fprintf(w, "%s", response)
}

func main() {
	http.HandleFunc("/get", handler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}