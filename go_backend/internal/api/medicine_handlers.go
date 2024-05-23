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

type GetMedicinesWithIdsMessage struct {
  MedicineIDs []int `json:"medicineIds"`
}

type UpdateMedicineMessage struct {
  MedicineID int `json:"medicineId"`
  PharmacyID int `json:"pharmacyId"`
  Quantity int `json:"quantity"`
}

type GetMedicineFromBarcodeMessage struct {
  Barcode string `json:"barcode"`
}

type getPharmaciesMessage struct {
	MedicineID int `json:"medicineId"`
}

type searchPharmaciesMessage struct {
	MedicineInput string `json:"medicineInput"`
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

func GetMedicinesFromPharmacyHandler(c *gin.Context) {
  var message GetMedicineMessage
  if err := c.ShouldBindJSON(&message); err != nil {
    c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
    utils.Error("Error binding JSON")
    return
  }
  medicines := db.GetMedicinesFromPharmacy(message.PharmacyID)
  c.JSON(http.StatusOK, gin.H{"medicinesInPharmacy": medicines})
}

func GetMedicinesWithIds(c *gin.Context) {
  var message GetMedicinesWithIdsMessage
  if err := c.ShouldBindJSON(&message); err != nil {
    c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
    utils.Error("Error binding JSON")
    return
  }
  medicines := db.GetMedicinesWithIds(message.MedicineIDs)
  c.JSON(http.StatusOK, gin.H{"medicines": medicines})
}

func GetMedicineFromBarcodeHandler(c *gin.Context) {
  var message GetMedicineFromBarcodeMessage
  if err := c.ShouldBindJSON(&message); err != nil {
    c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
    utils.Error("Error binding JSON")
    return
  }
  medicine := db.GetMedicineFromBarcode(message.Barcode)
  c.JSON(http.StatusOK, gin.H{"medicine": medicine})
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

func UpdateMedicineHandler(c *gin.Context) {
  var message UpdateMedicineMessage
  if err := c.ShouldBindJSON(&message); err != nil {
    c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
    utils.Error("Error binding JSON")
    return
  }

  db.UpdateMedicine(message.MedicineID, message.PharmacyID, message.Quantity)
  c.JSON(http.StatusOK, gin.H{"message": "Medicine purchased successfully"})
  utils.Info("Medicine purchased successfully")
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

func SearchPharmacyWithMedicineHandler(c *gin.Context) {
  var message searchPharmaciesMessage
	if err := c.ShouldBindJSON(&message); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	pharmacies := db.SearchPharmaciesWithMedicine(message.MedicineInput)
	c.JSON(http.StatusOK, gin.H{"pharmacies": pharmacies})
}
