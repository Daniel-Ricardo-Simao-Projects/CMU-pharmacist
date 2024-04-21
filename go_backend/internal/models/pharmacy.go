package models

type Pharmacy struct {
	Pharmacy_id int             `json:"pharmacy_id"`
	Name        string          `json:"name"`
	Location    string          `json:"location"`
	Picture     string          `json:"picture"`
	Stock       []MedicineStock `json:"medicine"`
}
