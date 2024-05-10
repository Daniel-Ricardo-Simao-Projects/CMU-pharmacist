package services

import (
	"errors"
	"fmt"
	db "go_backend/internal/database"
	models "go_backend/internal/models"
	utils "go_backend/internal/utils"
)

func AddUser(user models.User) error {
	// check if user already exists
	if db.GetUserByUsername(user.Username) != nil {
		utils.Error("User already exists")
		return errors.New("User already exists")
	}

	// check if user is valid
	if user.Username == "" || user.Password == "" {
		utils.Error("Invalid user")
		return errors.New("Invalid user")
	}

	db.AddUser(user)
	return nil
}

func AuthenticateUser(username, password string) (*models.User, error) {
	user := db.GetUserInfoByUsername(username)
	if user == nil {
		utils.Error("User not found")
		return nil, errors.New("User not found")
	}

	if user.Password != password {
		utils.Error("Invalid password")
		return nil, errors.New("Invalid password")
	}

	return user, nil
}

func GetFavoritePharmaciesByUsername(username string) []models.Pharmacy {
	id := db.GetIdByUsername(username)

	fmt.Println("GetFavoritePharmaciesByUsername: ", id)

	return db.GetFavoritePharmaciesByUsername(id)
}

func AddFavoritePharmacy(username string, pharmacyId int) error {
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

	db.AddFavoritePharmacy(id, pharmacyId)
	return nil
}

func RemoveFavoritePharmacy(username string, pharmacyId int) error {
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

	db.RemoveFavoritePharmacy(id, pharmacyId)
	return nil
}
