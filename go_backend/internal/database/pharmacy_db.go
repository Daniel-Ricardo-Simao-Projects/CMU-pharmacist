package database

import (
	"encoding/base64"
	_ "github.com/go-sql-driver/mysql"
	"log"
	"os"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
	utils "go_backend/internal/utils"
)

func GetPharmacies() []models.Pharmacy {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	rows, err := db.Query("SELECT * FROM pharmacies")
	if err != nil {
		log.Fatal(err)
	}

	pharmacies := []models.Pharmacy{}
	// iterate over each row, watch out: send picture as base64
	for rows.Next() {
		var pharmacy models.Pharmacy
		err := rows.Scan(&pharmacy.Id, &pharmacy.Name, &pharmacy.Address, &pharmacy.Picture, &pharmacy.Date)
		if err != nil {
			log.Fatal(err)
		}

		// read picture
		imageData, err := os.ReadFile(pharmacy.Picture)
		if err != nil {
			log.Fatal(err)
		}
		pharmacy.Picture = base64.StdEncoding.EncodeToString(imageData)

		pharmacies = append(pharmacies, pharmacy)
	}

	return pharmacies
}

func AddPharmacy(pharmacy models.Pharmacy) {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	imageData, err := base64.StdEncoding.DecodeString(pharmacy.Picture)
	if err != nil {
		log.Fatal(err)
	}

	// save picture (create directory if not exists)
	imagePath := "internal/images/" + pharmacy.Name + ".png"

	err = os.WriteFile(imagePath, imageData, 0644)
	if err != nil {
		log.Fatal(err)
	}

	// print picture
	utils.Info(pharmacy.Picture)

	_, err = db.Exec("INSERT INTO pharmacies (name, address, image_path) VALUES (?, ?, ?)", pharmacy.Name, pharmacy.Address, imagePath)
	if err != nil {
		log.Fatal(err)
	}
}
