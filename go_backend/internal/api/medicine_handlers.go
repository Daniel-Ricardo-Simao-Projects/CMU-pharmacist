package handlers

import (
	"fmt"
	"log"
	"net/http"
	// "time"

	"context"

	"firebase.google.com/go"
	"firebase.google.com/go/messaging"
	//	"google.golang.org/api/option"

	db "go_backend/internal/database"
	models "go_backend/internal/models"
	utils "go_backend/internal/utils"

	"github.com/gin-gonic/gin"
)

func sendNotification(token string, medicineName string, pharmacyName string) {
	utils.Info("Sending notification to token: " + token)

	ctx := context.Background()
	app1, err := firebase.NewApp(ctx, nil)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}

	client, err := app1.Messaging(ctx)
	if err != nil {
		log.Fatalf("error getting Messaging client: %v\n", err)
	}

	title := medicineName + " is now available in " + pharmacyName
	body := "Go to the app to see more details"

	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Token: token,
	}

	// Send message to the device
	response, err := client.Send(ctx, message)
	if err != nil {
		log.Fatalf("error sending message: %v\n", err)
	}
	fmt.Println("Successfully sent message:", response)
}

type GetMedicineMessage struct {
	PharmacyID int `json:"pharmacyId"`
}

type GetMedicinesWithIdsMessage struct {
	MedicineIDs []int `json:"medicineIds"`
}

type UpdateMedicineMessage struct {
	MedicineID int `json:"medicineId"`
	PharmacyID int `json:"pharmacyId"`
	Quantity   int `json:"quantity"`
}

type GetMedicineFromBarcodeMessage struct {
	Barcode string `json:"barcode"`
}

type GetPharmaciesMessage struct {
	MedicineID int `json:"medicineId"`
}

type GetPharmaciesWithIdsMessage struct {
	PharmacyIDs []int `json:"pharmacyIds"`
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

	id := db.GetIdByBarcode(newMedicine.Barcode)
	if id == -1 {
		utils.Info("Medicine does not exist")
	}

	notifications := db.GetNotificationsForMedicine(id)
	if len(notifications) > 0 {
		for _, notification := range notifications {
			if notification.MedicineId == id {
				userID := notification.UsernameID
				// get favorite pharmacies of user
				favoritePharmacies := db.GetFavoritePharmaciesByUsername(userID)
				// get pharmacy of new medicine
				pharmacy := newMedicine.PharmacyId
				// check if pharmacy of new medicine is in favorite pharmacies
				for _, favoritePharmacy := range favoritePharmacies {
					if favoritePharmacy.Id == pharmacy {
						// send notification to user
						sendNotification(db.GetTokenByUserId(userID), newMedicine.Name, favoritePharmacy.Name)
						db.RemoveNotification(notification)
						utils.Info("Notification sent to user: " + db.GetUserById(userID).Username)
					}
				}
			}
		}
	}

	db.AddMedicine(newMedicine)
	c.JSON(http.StatusCreated, gin.H{"message": "Medicine added successfully"})
	utils.Info("Medicine added successfully")
}

func AddMedicineHandlerUtils(newMedicine models.Medicine) {
	id := db.GetIdByBarcode(newMedicine.Barcode)
	if id == -1 {
		utils.Info("Medicine does not exist")
	}

	notifications := db.GetNotificationsForMedicine(id)
	if len(notifications) > 0 {
		for _, notification := range notifications {
			if notification.MedicineId == id {
				userID := notification.UsernameID
				// get favorite pharmacies of user
				favoritePharmacies := db.GetFavoritePharmaciesByUsername(userID)
				// get pharmacy of new medicine
				pharmacy := newMedicine.PharmacyId
				// check if pharmacy of new medicine is in favorite pharmacies
				for _, favoritePharmacy := range favoritePharmacies {
					if favoritePharmacy.Id == pharmacy {
						// send notification to user
						sendNotification(db.GetTokenByUserId(userID), newMedicine.Name, favoritePharmacy.Name)
						db.RemoveNotification(notification)
						utils.Info("Notification sent to user: " + db.GetUserById(userID).Username)
					}
				}
			}
		}
	}

	db.AddMedicine(newMedicine)
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
	var message GetPharmaciesMessage
	if err := c.ShouldBindJSON(&message); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	pharmacies := db.GetPharmaciesWithMedicine(message.MedicineID)
	c.JSON(http.StatusOK, gin.H{"pharmacies": pharmacies})
}

func GetPharmaciesWithMedicineWithCacheHandler(c *gin.Context) {
	var message GetPharmaciesMessage
	if err := c.ShouldBindJSON(&message); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	pharmacies := db.GetPharmaciesWithMedicineWithCache(message.MedicineID)
	c.JSON(http.StatusOK, gin.H{"pharmacies": pharmacies})
}

func GetPharmaciesWithIdsHandler(c *gin.Context) {
	var message GetPharmaciesWithIdsMessage
	if err := c.ShouldBindJSON(&message); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		utils.Error("Error binding JSON")
		return
	}

	pharmacies := db.GetPharmaciesWithIds(message.PharmacyIDs)
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

func AddNotificationHandler(c *gin.Context) {
	type RequestData struct {
		UserID     string `json:"userId"`
		MedicineID int    `json:"medicineId"`
	}

	var requestData RequestData

	if err := c.BindJSON(&requestData); err != nil {
		return
	}

	username := requestData.UserID
	medicineID := requestData.MedicineID

	// get user ID
	user := db.GetIdByUsername(username)

	// check if user is already notified
	notifications := db.GetNotificationsForMedicine(medicineID)
	if len(notifications) > 0 {
		for _, n := range notifications {
			if n.UsernameID == user {
				c.JSON(http.StatusOK, gin.H{"message": "User already notified"})
				utils.Info("User already notified")
				return
			}
		}
	}

	utils.Info("Sending notification to user: " + username + " for medicine: ")
	fmt.Println("AJAHJAHAHAHA", medicineID)

	db.AddNotification(models.Notification{UsernameID: user, MedicineId: medicineID})
	c.JSON(http.StatusCreated, gin.H{"message": "Notification added successfully"})
	utils.Info("Notification added successfully")
}

func IsNotifiedHandler(c *gin.Context) {
	type RequestData struct {
		UserID     string `json:"userId"`
		MedicineID int    `json:"medicineId"`
	}

	var requestData RequestData

	if err := c.BindJSON(&requestData); err != nil {
		return
	}

	username := requestData.UserID
	medicineID := requestData.MedicineID

	// get user ID
	user := db.GetIdByUsername(username)

	notification := models.Notification{UsernameID: user, MedicineId: medicineID}

	notifications := db.GetNotificationsForMedicine(notification.MedicineId)
	for _, n := range notifications {
		if n.UsernameID == notification.UsernameID {
			c.JSON(http.StatusOK, gin.H{"notified": true})
			utils.Info("User is notified")
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"notified": false})
	utils.Info("User is not notified")
}

func DeleteNotificationHandler(c *gin.Context) {
	type RequestData struct {
		UserID     string `json:"userId"`
		MedicineID int    `json:"medicineId"`
	}

	var requestData RequestData

	if err := c.BindJSON(&requestData); err != nil {
		return
	}

	username := requestData.UserID
	medicineID := requestData.MedicineID

	// get user ID
	user := db.GetIdByUsername(username)

	notification := models.Notification{UsernameID: user, MedicineId: medicineID}

	fmt.Println("DeleteNotificationHandler: ", notification)

	db.RemoveNotification(notification)
	c.JSON(http.StatusOK, gin.H{"message": "Notification removed successfully"})
	utils.Info("Notification removed successfully")
}
