package database

import (
	"encoding/base64"
	"log"
	"os"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
)

func GetFavoritePharmaciesByUsername(username int) []models.Pharmacy {
	rows, err := config.DB.Query("SELECT * FROM favorites WHERE user_id = ?", username)
	if err != nil {
		log.Fatal(err)
	}

	favoritePharmacies := []models.Pharmacy{}
	for rows.Next() {
		var favoritePharmacy models.FavoritePharmacy
		err := rows.Scan(&favoritePharmacy.UsernameId, &favoritePharmacy.PharmacyId)
		if err != nil {
			log.Fatal(err)
		}

		var pharmacy models.Pharmacy
		err = config.DB.QueryRow("SELECT * FROM pharmacies WHERE id = ?", favoritePharmacy.PharmacyId).
			Scan(&pharmacy.Id, &pharmacy.Name, &pharmacy.Address, &pharmacy.Picture, &pharmacy.Latitude, &pharmacy.Longitude, &pharmacy.Date)
		if err != nil {
			log.Fatal(err)
		}

		// read picture
		imageData, err := os.ReadFile(pharmacy.Picture)
		if err != nil {
			log.Fatal(err)
		}
		pharmacy.Picture = base64.StdEncoding.EncodeToString(imageData)

		favoritePharmacies = append(favoritePharmacies, pharmacy)
	}

	return favoritePharmacies
}

func AddFavoritePharmacy(username, pharmacyId int) {
	_, err := config.DB.Exec("INSERT INTO favorites (user_id, pharmacy_id) VALUES (?, ?)", username, pharmacyId)
	if err != nil {
		log.Print(err)
	}
}

func RemoveFavoritePharmacy(username, pharmacyId int) {
	_, err := config.DB.Exec("DELETE FROM favorites WHERE user_id = ? AND pharmacy_id = ?", username, pharmacyId)
	if err != nil {
		log.Fatal(err)
	}
}

func GetIdByUsername(username string) int {
	row := config.DB.QueryRow("SELECT id FROM users WHERE username = ?", username)

	var id int
	err := row.Scan(&id)
	if err != nil {
		log.Fatal(err)
	}

	return id
}
