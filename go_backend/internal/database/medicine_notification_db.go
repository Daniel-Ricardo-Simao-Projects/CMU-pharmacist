package database

import (
	"log"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
	//utils "go_backend/internal/utils"
)

func GetNotificationsForMedicine(medicineId int) []models.Notification {
	rows, err := config.DB.Query("SELECT * FROM notifications WHERE medicine_id = ?", medicineId)
	if err != nil {
		log.Fatal(err)
	}

	notifications := []models.Notification{}
	for rows.Next() {
		var notification models.Notification
		err := rows.Scan(&notification.Id, &notification.UsernameID, &notification.MedicineId)
		if err != nil {
			log.Fatal(err)
		}

		notifications = append(notifications, notification)
	}

	return notifications
}

func AddNotification(notification models.Notification) {
	_, err := config.DB.Exec("INSERT INTO notifications (user_id, medicine_id) VALUES (?, ?)", notification.UsernameID, notification.MedicineId)
	if err != nil {
		log.Fatal(err)
	}
}

func RemoveNotification(notification models.Notification) {
	_, err := config.DB.Exec("DELETE FROM notifications WHERE user_id = ? AND medicine_id = ?", notification.UsernameID, notification.MedicineId)
	if err != nil {
		log.Fatal(err)
	}
}
