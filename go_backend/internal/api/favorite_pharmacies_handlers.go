package handlers

import (
	"net/http"

	service "go_backend/internal/services"
	// utils "go_backend/internal/utils"

	"github.com/gin-gonic/gin"
)

func AddFavoritePharmacyHandler(c *gin.Context) {
	type RequestData struct {
		UserID     string `json:"userId"`
		PharmacyID int    `json:"pharmacyId"`
	}

	var requestData RequestData

	if err := c.BindJSON(&requestData); err != nil {
		return
	}

	username := requestData.UserID
	pharmacyId := requestData.PharmacyID

	service.AddFavoritePharmacy(username, pharmacyId)

	c.JSON(http.StatusOK, gin.H{"message": "Pharmacy added to favorites"})
}

func RemoveFavoritePharmacyHandler(c *gin.Context) {
	// retrieve username and pharmacyId from 'data' in the request
	type RequestData struct {
		UserID     string `json:"userId"`
		PharmacyID int    `json:"pharmacyId"`
	}

	var requestData RequestData

	if err := c.BindJSON(&requestData); err != nil {
		return
	}

	username := requestData.UserID
	pharmacyId := requestData.PharmacyID

	service.RemoveFavoritePharmacy(username, pharmacyId)

	c.JSON(http.StatusOK, gin.H{"message": "Pharmacy removed from favorites"})
}

func GetFavoritePharmaciesHandler(c *gin.Context) {
	type RequestData struct {
		UserID string `json:"userId"`
	}

	// Create a request data object
	var requestData RequestData

	// Bind the request body to the request data object
	if err := c.BindJSON(&requestData); err != nil {
		// Handle binding error
		return
	}

	pharmacies := service.GetFavoritePharmaciesByUsername(requestData.UserID)

	c.JSON(http.StatusOK, gin.H{"pharmacies": pharmacies})
}
