package handlers

import (
	"net/http"

	db "go_backend/internal/database"
	models "go_backend/internal/models"

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
		return
	}

  db.AddPharmacy(newPharmacy)
	c.JSON(http.StatusCreated, gin.H{"message": "Pharmacy added successfully"})
}
