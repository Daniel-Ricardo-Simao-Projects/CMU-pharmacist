package main

import (
	config "go_backend/internal/config"
	"log"
)

func main() {
	if err := config.OpenDB(); err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB()

	config.ResetDatabase()

}
