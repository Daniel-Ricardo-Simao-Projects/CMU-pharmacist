package services

import (
	"errors"
	"fmt"
	db "go_backend/internal/database"
	utils "go_backend/internal/utils"
)

func UpdatePharmacyRatingByUser(username string, pharmacyId int, rating int) error {
	id := db.GetIdByUsername(username)

	// check if user exists
	if db.GetUserById(id) == nil {
		utils.Error("User not found")
		return errors.New("User not found")
	}

	// check if pharmacy exists
	if db.GetPharmacyById(pharmacyId) == nil {
		utils.Error("Pharmacy not found")
		return errors.New("Pharmacy not found")
	}

	fmt.Println("UpdatePharmacyRatingByUser: ", id, pharmacyId, rating)

	// check if user already rated pharmacy
	db.AddPharmacyRating(id, pharmacyId, rating)
	return nil
}

func GetPharmacyRatingByUser(username string, pharmacyId int) int {
	id := db.GetIdByUsername(username)

	// check if user exists
	if db.GetUserById(id) == nil {
		utils.Error("User not found")
		return -1
	}

	// check if pharmacy exists
	if db.GetPharmacyById(pharmacyId) == nil {
		utils.Error("Pharmacy not found")
		return -1
	}

	// get rating
	rating := db.GetPharmacyRatingByUser(id, pharmacyId)
	fmt.Println("GetPharmacyRatingByUser: ", rating)
	return rating
}

func GetPharmacyRating(pharmacyId int) int {
	rating := db.GetAveragePharmacyRating(pharmacyId)
	// transform float64 to int (round)
	return int(rating)
}

func GetPharmacyRatingHistogram(pharmacyId int) map[int]int {
	histogram := db.GetRatingDistribution(pharmacyId)

	return histogram
}
