package main

import (
	config "go_backend/internal/config"
	"go_backend/internal/services"
	"log"
)

func main() {
	if err := config.OpenDB(); err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB()

	services.PopulateDatabase()
}
