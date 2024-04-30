package handlers

import (
	"net/http"

	db "go_backend/internal/database"
	models "go_backend/internal/models"
	utils "go_backend/internal/utils"

	"github.com/gin-gonic/gin"
)

// TODO: implement GetMedicineHandler
func GetMedicineHandler(c *gin.Context) {
  var medicine models.Medicine
	if err := c.ShouldBindJSON(&medicine); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}
	// medicines := db.GetMedicines(medicine.PharmacyId)

	// c.JSON(http.StatusOK, gin.H{"medicines": medicines})
}

func AddMedicineHandler(c *gin.Context) {
	var newMedicine models.Medicine
	if err := c.ShouldBindJSON(&newMedicine); err != nil {
    println(c.Keys)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	db.AddMedicine(newMedicine)
	c.JSON(http.StatusCreated, gin.H{"message": "Medicine added successfully"})
	utils.Info("Medicine added successfully")
}
