package database

import (
	"database/sql"
	"encoding/base64"
	"log"
	"os"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
	utils "go_backend/internal/utils"
)

// TODO: implement GetMedicines
// func GetMedicines(pharmacyId int) []models.Medicine {
// 	rows, err := config.DB.Query("SELECT * FROM pharmacies")
// 	if err != nil {
// 		log.Fatal(err)
// 	}
//
// 	pharmacies := []models.Pharmacy{}
// 	// iterate over each row, watch out: send picture as base64
// 	for rows.Next() {
// 		var pharmacy models.Pharmacy
// 		err := rows.Scan(&pharmacy.Id, &pharmacy.Name, &pharmacy.Address, &pharmacy.Picture, &pharmacy.Date)
// 		if err != nil {
// 			log.Fatal(err)
// 		}
//
// 		// read picture
// 		imageData, err := os.ReadFile(pharmacy.Picture)
// 		if err != nil {
// 			log.Fatal(err)
// 		}
// 		pharmacy.Picture = base64.StdEncoding.EncodeToString(imageData)
//
// 		pharmacies = append(pharmacies, pharmacy)
// 	}
//
// 	return pharmacies
// }

func AddMedicine(medicine models.Medicine) {
	imageData, err := base64.StdEncoding.DecodeString(medicine.Picture)
	if err != nil {
		log.Fatal(err)
	}

	// save picture (create directory if not exists)
	imagePath := "internal/images/medicines/" + medicine.Name + ".png"

	err = os.WriteFile(imagePath, imageData, 0644)
	if err != nil {
		log.Fatal(err)
	}

	// print picture
	utils.Info(medicine.Picture)

	var medicineId int
	err = config.DB.QueryRow("SELECT id FROM medicines WHERE name = ?", medicine.Name).Scan(&medicineId)
	if err != nil && err != sql.ErrNoRows {
		log.Fatal(err)
	}

	// Register new medicine in the system
	if medicineId == 0 {
		_, err = config.DB.Exec("INSERT INTO medicines (name, details, image_path) VALUES (?, ?, ?)", medicine.Name, medicine.Details, imagePath)
		if err != nil {
			log.Fatal(err)
		}

    // Get the medicine id
		err = config.DB.QueryRow("SELECT id FROM medicines WHERE name = ?", medicine.Name).Scan(&medicineId)
		if err != nil && err != sql.ErrNoRows {
			log.Fatal(err)
		}
	}

	_, err = config.DB.Exec("INSERT INTO medicine_pharmacy (medicine_id, pharmacy_id, stock) VALUES (?, ?, ?)", medicineId, medicine.PharmacyId, medicine.Stock)
	if err != nil {
		log.Fatal(err)
	}

}
