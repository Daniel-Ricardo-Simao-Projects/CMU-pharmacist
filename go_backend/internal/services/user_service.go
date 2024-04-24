package services

import (
	"errors"
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
