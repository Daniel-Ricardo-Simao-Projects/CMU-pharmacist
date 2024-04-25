package config

import (
	"log"
	"os"
)

func RemoveImagesDir() {
	// remove images directory (internal/images)
	err := os.RemoveAll("internal/images/pharmacies")
	if err != nil {
		log.Fatal(err)
	}

	// create directory if not exists
	err = os.MkdirAll("internal/images/pharmacies", 0755)
	if err != nil {
		log.Fatal(err)
	}
}
