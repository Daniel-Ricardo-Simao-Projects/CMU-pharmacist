package models

type Pharmacy struct {
	Id      int             `json:"id"`
	Name    string          `json:"name"`
	Address string          `json:"address"`
	Picture string          `json:"picture"`
	Date    string          `json:"date"`
	Stock   []MedicineStock `json:"medicine"`
}
