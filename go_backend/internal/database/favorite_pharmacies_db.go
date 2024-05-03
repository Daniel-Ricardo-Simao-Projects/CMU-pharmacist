package database

import (
	"log"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
)

func GetFavoritePharmaciesByUsername(username string) []models.Pharmacy {
	rows, err := config.DB.Query("SELECT * FROM favorites WHERE username = ?", username)
	if err != nil {
		log.Fatal(err)
	}

	favoritePharmacies := []models.Pharmacy{}
	for rows.Next() {
		var favoritePharmacy models.FavoritePharmacy
		err := rows.Scan(&favoritePharmacy.Id, &favoritePharmacy.Username, &favoritePharmacy.PharmacyId)
		if err != nil {
			log.Fatal(err)
		}

		var pharmacy models.Pharmacy
		err = config.DB.QueryRow("SELECT * FROM pharmacies WHERE id = ?", favoritePharmacy.PharmacyId).
			Scan(&pharmacy.Id, &pharmacy.Name, &pharmacy.Address, &pharmacy.Picture, &pharmacy.Date)
		if err != nil {
			log.Fatal(err)
		}

		favoritePharmacies = append(favoritePharmacies, pharmacy)
	}

	return favoritePharmacies
}
