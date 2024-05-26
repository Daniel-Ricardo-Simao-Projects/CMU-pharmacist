package models

type Notification struct {
	Id         int `json:"id"`
	MedicineId int `json:"medicineId"`
	UsernameID int `json:"user"`
}
