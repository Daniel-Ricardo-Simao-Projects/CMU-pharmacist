package handlers

import (
	"net/http"

	db "go_backend/internal/database"
	models "go_backend/internal/models"
	service "go_backend/internal/services"
	utils "go_backend/internal/utils"

	"github.com/gin-gonic/gin"
)

func GetPharmacyHandler(c *gin.Context) {
	pharmacies := db.GetPharmacies()

	c.JSON(http.StatusOK, gin.H{"pharmacies": pharmacies})
}

func AddPharmacyHandler(c *gin.Context) {
	var newPharmacy models.Pharmacy
	if err := c.ShouldBindJSON(&newPharmacy); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	db.AddPharmacy(newPharmacy)
	c.JSON(http.StatusCreated, gin.H{"message": "Pharmacy added successfully"})
	utils.Info("Pharmacy added successfully")
}

func AddPharmacyRatingHandler(c *gin.Context) {
	type Rating struct {
		Username   string `json:"username"`
		PharmacyId int    `json:"pharmacy_id"`
		Rating     int    `json:"rating"`
	}

	var newRating Rating

	if err := c.ShouldBindJSON(&newRating); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	service.UpdatePharmacyRatingByUser(newRating.Username, newRating.PharmacyId, newRating.Rating)
	c.JSON(http.StatusCreated, gin.H{"message": "Rating added successfully"})
	utils.Info("Rating added successfully")
}

func GetPharmacyRatingByUserHandler(c *gin.Context) {
	type Rating struct {
		Username   string `json:"username"`
		PharmacyId int    `json:"pharmacy_id"`
	}

	var rating Rating

	if err := c.ShouldBindJSON(&rating); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	ratingValue := service.GetPharmacyRatingByUser(rating.Username, rating.PharmacyId)

	c.JSON(http.StatusOK, gin.H{"rating": ratingValue})
	utils.Info("Rating retrieved successfully")
}

func GetPharmacyAverageRatingHandler(c *gin.Context) {
	type PharmacyId struct {
		PharmacyId int `json:"pharmacy_id"`
	}

	var pharmacyId PharmacyId

	if err := c.ShouldBindJSON(&pharmacyId); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	ratingValue := service.GetPharmacyRating(pharmacyId.PharmacyId)

	c.JSON(http.StatusOK, gin.H{"rating": ratingValue})
	utils.Info("Rating retrieved successfully")
}

func GetPharmacyRatingHistogramHandler(c *gin.Context) {
	type PharmacyId struct {
		PharmacyId int `json:"pharmacy_id"`
	}

	var pharmacyId PharmacyId

	if err := c.ShouldBindJSON(&pharmacyId); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	// histogram is a map[int]int
	histogram := service.GetPharmacyRatingHistogram(pharmacyId.PharmacyId)

	c.JSON(http.StatusOK, gin.H{"histogram": histogram})
	utils.Info("Histogram retrieved successfully")
}
