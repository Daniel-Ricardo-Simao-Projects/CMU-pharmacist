package handlers

import (
	"net/http"

	db "go_backend/internal/database"
	models "go_backend/internal/models"
	utils "go_backend/internal/utils"

	"github.com/gin-gonic/gin"
)

type GetMedicineMessage struct {
	PharmacyID int `json:"pharmacyId"`
}

type getPharmaciesMessage struct {
	MedicineID int `json:"medicineId"`
}

func GetMedicineHandler(c *gin.Context) {
	var message GetMedicineMessage
	if err := c.ShouldBindJSON(&message); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}
	medicines := db.GetMedicines(message.PharmacyID)

	c.JSON(http.StatusOK, gin.H{"medicines": medicines})
}

func AddMedicineHandler(c *gin.Context) {
	var newMedicine models.Medicine
	if err := c.ShouldBindJSON(&newMedicine); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	db.AddMedicine(newMedicine)
	c.JSON(http.StatusCreated, gin.H{"message": "Medicine added successfully"})
	utils.Info("Medicine added successfully")
}

func GetPharmacyWithMedicineHandler(c *gin.Context) {
  var message getPharmaciesMessage
  if err := c.ShouldBindJSON(&message); err != nil {
    c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
    utils.Error("Error binding JSON")
    return
  }

  pharmacies := db.GetPharmaciesWithMedicine(message.MedicineID)
  c.JSON(http.StatusOK, gin.H{"pharmacies": pharmacies})
}
