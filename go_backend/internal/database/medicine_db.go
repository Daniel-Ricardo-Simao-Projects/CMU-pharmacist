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

func GetMedicines(pharmacyId int) []models.Medicine {
	rows, err := config.DB.Query("SELECT * FROM medicine_pharmacy WHERE pharmacy_id = ?", pharmacyId)
	if err != nil {
		log.Fatal(err)
	}

	medicines := []models.Medicine{}
	for rows.Next() {
		var medicine models.Medicine
		err := rows.Scan(&medicine.Id, &medicine.PharmacyId, &medicine.Stock)
		if err != nil {
			log.Fatal(err)
		}
		var image_path string
		err = config.DB.QueryRow("SELECT * FROM medicines WHERE id = ?", medicine.Id).
			Scan(&medicine.Id, &medicine.Name, &medicine.Details, &image_path)

		if err != nil {
			log.Fatal(err)
		}

		imageData, err := os.ReadFile(image_path)
		if err != nil {
			log.Fatal(err)
		}
		medicine.Picture = base64.StdEncoding.EncodeToString(imageData)

		medicines = append(medicines, medicine)
	}

	return medicines
}

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

func GetPharmaciesWithMedicine(medicineId int) []models.Pharmacy {
	rows, err := config.DB.Query("SELECT pharmacy_id, stock FROM medicine_pharmacy WHERE medicine_id = ?", medicineId)
	if err != nil {
		log.Fatal(err)
	}

	pharmacies := []models.Pharmacy{}
	for rows.Next() {
		var pharmacy models.Pharmacy
		var stock int

		err := rows.Scan(&pharmacy.Id, &stock)
		if err != nil {
			log.Fatal(err)
		}

		if stock == 0 {
			continue
		}

		var image_path string
		err = config.DB.QueryRow("SELECT name, address, image_path FROM pharmacies WHERE id = ?", pharmacy.Id).
			Scan(&pharmacy.Name, &pharmacy.Address, &image_path)
		if err != nil {
			log.Fatal(err)
		}

		imageData, err := os.ReadFile(image_path)
		if err != nil {
			log.Fatal(err)
		}
		pharmacy.Picture = base64.StdEncoding.EncodeToString(imageData)

		pharmacies = append(pharmacies, pharmacy)
	}

	return pharmacies
}
