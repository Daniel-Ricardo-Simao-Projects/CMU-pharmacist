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

func AddPharmacyRating(userId, pharmacyId, rating int) {
	// check if user already rated pharmacy
	row := config.DB.QueryRow("SELECT * FROM pharmacy_ratings WHERE user_id = ? AND pharmacy_id = ?", userId, pharmacyId)
	var userRating int
	err := row.Scan(&userRating)
	if err == nil {
		UpdatePharmacyRating(userId, pharmacyId, rating)
		return
	}

	_, err = config.DB.Exec("INSERT INTO pharmacy_ratings (user_id, pharmacy_id, rating) VALUES (?, ?, ?)", userId, pharmacyId, rating)
	if err != nil {
		log.Fatal(err)
	}

	return
}

func UpdatePharmacyRating(userId, pharmacyId, rating int) {
	_, err := config.DB.Exec("UPDATE pharmacy_ratings SET rating = ? WHERE user_id = ? AND pharmacy_id = ?", rating, userId, pharmacyId)
	if err != nil {
		log.Fatal(err)
	}

	return
}

func GetAveragePharmacyRating(pharmacyId int) float64 {
	row := config.DB.QueryRow("SELECT pharmacy_id, AVG(rating) AS average_rating FROM pharmacy_ratings WHERE pharmacy_id = ?", pharmacyId)

	var pharmacyIdInt int

	var averageRating float64

	err := row.Scan(&pharmacyIdInt, &averageRating)

	if err != nil {
		return 0
	}

	// send average rating as int (0-5)
	return averageRating
}

func GetRatingDistribution(pharmacyId int) map[int]int {
	rows, err := config.DB.Query("SELECT rating, COUNT(rating) AS count FROM pharmacy_ratings WHERE pharmacy_id = ? GROUP BY rating", pharmacyId)
	if err != nil {
		log.Fatal(err)
	}

	ratingDistribution := make(map[int]int)
	for rows.Next() {
		var rating, count int
		err := rows.Scan(&rating, &count)
		if err != nil {
			log.Fatal(err)
		}

		ratingDistribution[rating] = count
	}

	return ratingDistribution
}

func GetPharmacyRatingByUser(userId, pharmacyId int) int {
	row := config.DB.QueryRow("SELECT rating FROM pharmacy_ratings WHERE user_id = ? AND pharmacy_id = ?", userId, pharmacyId)

	var rating int
	err := row.Scan(&rating)
	if err != nil {
		return -1
	}

	return rating
}
