package handlers

import (
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
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	if err := services.AuthenticateUser(user.Username, user.Password); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		utils.Error("Error authenticating user")
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User authenticated successfully"})
	utils.Info("User authenticated successfully")
}

func AddUserHandler(c *gin.Context) {
	var newUser models.User
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

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
