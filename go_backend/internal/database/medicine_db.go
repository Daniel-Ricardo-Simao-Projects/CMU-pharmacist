package database

import (
	"database/sql"
	"encoding/base64"
	"log"
	"os"
	"strings"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
	//utils "go_backend/internal/utils"
)

// TODO: This will probably be removed
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

		if medicine.Stock == 0 {
			continue
		}

		var image_path string
		err = config.DB.QueryRow("SELECT * FROM medicines WHERE id = ?", medicine.Id).
			Scan(&medicine.Id, &medicine.Name, &medicine.Details, &image_path, &medicine.Barcode)

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

func GetMedicinesFromPharmacy(pharmacyId int) []models.MedicineFromPharmacy {
	rows, err := config.DB.Query("SELECT * FROM medicine_pharmacy WHERE pharmacy_id = ?", pharmacyId)
	if err != nil {
		log.Fatal(err)
	}

	medicines := []models.MedicineFromPharmacy{}
	for rows.Next() {
		var medicine models.MedicineFromPharmacy
		err := rows.Scan(&medicine.MedicineId, &medicine.PharmacyId, &medicine.Stock)
		if err != nil {
			log.Fatal(err)
		}

		if medicine.Stock == 0 {
			continue
		}
		medicines = append(medicines, medicine)
	}

	return medicines
}

func GetMedicinesWithIds(medicineIds []int) []models.Medicine {
	medicines := []models.Medicine{}
	println("Received Medicine IDs: ")
	for _, medicineId := range medicineIds {
		println(medicineId)
		var medicine models.Medicine
		var image_path string
		err := config.DB.QueryRow("SELECT * FROM medicines WHERE id = ?", medicineId).
			Scan(&medicine.Id, &medicine.Name, &medicine.Details, &image_path, &medicine.Barcode)
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

func GetMedicineFromBarcode(barcode string) models.Medicine {
	var medicine models.Medicine
	var image_path string
	err := config.DB.QueryRow("SELECT * FROM medicines WHERE barcode = ?", barcode).
		Scan(&medicine.Id, &medicine.Name, &medicine.Details, &image_path, &medicine.Barcode)
	if err != nil {
		if err == sql.ErrNoRows {
			return models.Medicine{Id: 0,
				Name:       "",
				Details:    "",
				Picture:    "",
				Barcode:    "",
				PharmacyId: 0,
				Stock:      0,
			}
		}
		log.Fatal(err)
	}

	imageData, err := os.ReadFile(image_path)
	if err != nil {
		log.Fatal(err)
	}
	medicine.Picture = base64.StdEncoding.EncodeToString(imageData)

	return medicine
}

func AddMedicine(medicine models.Medicine) {
	var medicineId int

	// Find if medicine already exists
	err := config.DB.QueryRow("SELECT id FROM medicines WHERE barcode = ?", medicine.Barcode).Scan(&medicineId)
	if err != nil && err != sql.ErrNoRows {
		log.Fatal(err)
	}

	if medicineId != 0 { // Only add medicine to pharmacy
		var id int
		err := config.DB.QueryRow("SELECT medicine_id FROM medicine_pharmacy WHERE medicine_id = ? AND pharmacy_id = ?", medicineId, medicine.PharmacyId).Scan(&id)

		// If medicine is not in pharmacy add to it
		if err == sql.ErrNoRows {
			_, err = config.DB.Exec("INSERT INTO medicine_pharmacy (medicine_id, pharmacy_id, stock) VALUES (?, ?, ?)", medicineId, medicine.PharmacyId, medicine.Stock)
			if err != nil {
				log.Fatal(err)
			}
			return
		} else if err != nil {
			log.Fatal(err)
		} else { // If medicine is already in pharmacy update stock
			_, err = config.DB.Exec("UPDATE medicine_pharmacy SET stock = stock + ? WHERE medicine_id = ? AND pharmacy_id = ?", medicine.Stock, medicineId, medicine.PharmacyId)
			if err != nil {
				log.Fatal(err)
			}
			return
		}
	}

	// Register new medicine in the system
	imageData, err := base64.StdEncoding.DecodeString(medicine.Picture)
	if err != nil {
		log.Fatal(err)
	}

	// save picture (create directory if not exists)
	// trim spaces from medicine name
	medicine.Name = strings.TrimSpace(medicine.Name)
	medicinePathName := strings.ReplaceAll(medicine.Name, " ", "_")
	imagePath := "internal/images/medicines/" + medicinePathName + ".png"

	err = os.WriteFile(imagePath, imageData, 0644)
	if err != nil {
		log.Fatal(err)
	}

	// print picture
	//utils.Info(medicine.Picture)

	err = config.DB.QueryRow("SELECT id FROM medicines WHERE name = ?", medicine.Name).Scan(&medicineId)
	if err != nil && err != sql.ErrNoRows {
		log.Fatal(err)
	}

	// Register new medicine in the system
	if medicineId == 0 {
		_, err = config.DB.Exec("INSERT INTO medicines (name, details, image_path, barcode) VALUES (?, ?, ?, ?)", medicine.Name, medicine.Details, imagePath, medicine.Barcode)
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

func UpdateMedicine(medicineId, pharmacyId, quantity int) {
	_, err := config.DB.Exec("UPDATE medicine_pharmacy SET stock = stock - ? WHERE medicine_id = ? AND pharmacy_id = ?", quantity, medicineId, pharmacyId)
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

func GetPharmaciesWithMedicineWithCache(medicineId int) []models.MedicineFromPharmacy {
	rows, err := config.DB.Query("SELECT * FROM medicine_pharmacy WHERE medicine_id = ?", medicineId)
	if err != nil {
		log.Fatal(err)
	}

	pharmacies := []models.MedicineFromPharmacy{}
	for rows.Next() {
		var pharmacy models.MedicineFromPharmacy

		err := rows.Scan(&pharmacy.MedicineId, &pharmacy.PharmacyId, &pharmacy.Stock)
		if err != nil {
			log.Fatal(err)
		}

		if pharmacy.Stock == 0 {
			continue
		}

		pharmacies = append(pharmacies, pharmacy)
	}

	return pharmacies
}

func GetPharmaciesWithIds(pharmacyIds []int) []models.Pharmacy {
  pharmacies := []models.Pharmacy{}
  for _, pharmacyId := range pharmacyIds {
    var pharmacy models.Pharmacy
    var image_path string
    err := config.DB.QueryRow("SELECT id, name, address, image_path FROM pharmacies WHERE id = ?", pharmacyId).
      Scan(&pharmacy.Id, &pharmacy.Name, &pharmacy.Address, &image_path)
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

func SearchPharmaciesWithMedicine(medicineInput string) []models.Pharmacy {
	// TODO: Maybe sanitize input (?)
	medicineInput = "%" + medicineInput + "%"
	medicineRows, err := config.DB.Query("SELECT id FROM medicines WHERE name LIKE ?", medicineInput)
	if err != nil {
		log.Fatal(err)
	}

	pharmacies := []models.Pharmacy{}
	for medicineRows.Next() {
		var medicineId string
		err := medicineRows.Scan(&medicineId)
		if err != nil {
			log.Fatal(err)
		}
		connectionRows, err := config.DB.Query("SELECT pharmacy_id, stock FROM medicine_pharmacy WHERE medicine_id = ?", medicineId)
		if err != nil {
			log.Fatal(err)
		}
		for connectionRows.Next() {
			var pharmacy models.Pharmacy
			var stock int

			err := connectionRows.Scan(&pharmacy.Id, &stock)
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

			//TODO: Order pharmacies by distance
		}
	}

	return pharmacies
}
