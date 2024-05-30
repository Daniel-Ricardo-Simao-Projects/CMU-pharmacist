package models

type Pharmacy struct {
	Id        int     `json:"id"`
	Name      string  `json:"name"`
	Address   string  `json:"address"`
	Picture   string  `json:"picture"`
	Latitude  float32 `json:"latitude"`
	Longitude float32 `json:"longitude"`
	Date      string  `json:"date"`
}
