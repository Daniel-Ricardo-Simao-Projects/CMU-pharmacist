package database

import (
	_ "github.com/go-sql-driver/mysql"
	"log"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
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
	for rows.Next() {
    var pharmacy models.Pharmacy
    err := rows.Scan(&pharmacy.Id, &pharmacy.Name, &pharmacy.Address, &pharmacy.Picture, &pharmacy.Date)
		if err != nil {
			log.Fatal(err)
		}
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

	_, err = db.Exec("INSERT INTO pharmacies (name, address, image_path) VALUES (?, ?, ?)", pharmacy.Name, pharmacy.Address, pharmacy.Picture)
	if err != nil {
		log.Fatal(err)
	}
}

