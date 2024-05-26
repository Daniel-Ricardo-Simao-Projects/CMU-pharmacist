package handlers

import (
	"fmt"
	"net/http"
	"strconv"

	db "go_backend/internal/database"
	models "go_backend/internal/models"
	services "go_backend/internal/services"
	utils "go_backend/internal/utils"

	"github.com/gin-gonic/gin"
)

func GetUsersHandler(c *gin.Context) {
	users := db.GetUsers()

	c.JSON(http.StatusOK, gin.H{"Users": users})
}

func AuthenticateUserHandler(c *gin.Context) {
	type UserAuth struct {
		Username string `json:"username"`
		Password string `json:"password"`
		FCMToken string `json:"fcm_token"`
	}

	var userAuth UserAuth

	if err := c.ShouldBindJSON(&userAuth); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	utils.Info("User: " + userAuth.Username + " is trying to authenticate with token: " + userAuth.FCMToken)

	// create user
	user := models.User{
		Username: userAuth.Username,
		Password: userAuth.Password,
	}

	userInfo, err := services.AuthenticateUser(user.Username, user.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		utils.Error("Error authenticating user")
		return
	}

	// log user info
	if userInfo != nil {
		fmt.Println("User authenticated: ", userInfo)
	}

	// add fcm token
	err = db.AddFCMToken(userAuth.Username, userAuth.FCMToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		utils.Error("Error adding FCM token")
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": userInfo})
	utils.Info("User authenticated successfully")
}

func AddUserHandler(c *gin.Context) {
	var newUser models.User
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	fmt.Println("New user: ", newUser.Username, newUser.Password)

	// db.AddUser(newUser)
	err := services.AddUser(newUser)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		utils.Error("Error adding user")
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "User added successfully"})
	utils.Info("User added successfully")
}

func UpdateUserHandler(c *gin.Context) {
	var updatedUser models.User
	if err := c.ShouldBindJSON(&updatedUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	if db.UpdateUser(updatedUser) == nil {
		c.JSON(http.StatusOK, gin.H{"message": "User updated successfully"})
		utils.Info("User updated successfully")
		return
	}

	c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
	utils.Error("User not found")
}

func DeleteUserHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		utils.Error("Invalid user ID")
		return
	}

	if db.DeleteUser(id) != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		utils.Error("User not found")
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User deleted successfully"})
	utils.Info("User deleted successfully")
}
