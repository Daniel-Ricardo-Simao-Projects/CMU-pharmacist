package models

type Medicine struct {
	Id         int    `json:"id"`
	Name       string `json:"name"`
	Details    string `json:"details"`
	Picture    string `json:"picture"`
	Stock      int    `json:"stock"`
	PharmacyId int    `json:"pharmacyId"`
}
