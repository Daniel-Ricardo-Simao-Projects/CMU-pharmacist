package database

import (
	"encoding/base64"
	"log"
	"os"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
)

func GetPharmacies() []models.Pharmacy {
	rows, err := config.DB.Query("SELECT * FROM pharmacies")
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
	imageData, err := base64.StdEncoding.DecodeString(pharmacy.Picture)
	if err != nil {
		log.Fatal(err)
	}

	// save picture (create directory if not exists)
	imagePath := "internal/images/pharmacies/" + pharmacy.Name + ".png"

	err = os.WriteFile(imagePath, imageData, 0644)
	if err != nil {
		log.Fatal(err)
	}

	// print picture
	//utils.Info(pharmacy.Picture)

	_, err = config.DB.Exec("INSERT INTO pharmacies (name, address, image_path) VALUES (?, ?, ?)", pharmacy.Name, pharmacy.Address, imagePath)
	if err != nil {
		log.Fatal(err)
	}
}

func GetPharmacyById(id int) *models.Pharmacy {
	row := config.DB.QueryRow("SELECT * FROM pharmacies WHERE id = ?", id)

	var pharmacy models.Pharmacy
	err := row.Scan(&pharmacy.Id, &pharmacy.Name, &pharmacy.Address, &pharmacy.Picture, &pharmacy.Date)
	if err != nil {
		return nil
	}

	// read picture
	imageData, err := os.ReadFile(pharmacy.Picture)
	if err != nil {
		log.Fatal(err)
	}

	pharmacy.Picture = base64.StdEncoding.EncodeToString(imageData)

	return &pharmacy
}
