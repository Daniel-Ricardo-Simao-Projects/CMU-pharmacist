package data

type User struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type Favorites struct {
	Username         string `json:"username"`
	Pharmacy_id      int    `json:"pharmacy_id"`
	NotificationFlag bool   `json:"notification_flag"`
}

type Map struct {
	Pharmacies []Pharmacy `json:"pharmacies"`
}

type Pharmacy struct {
	Pharmacy_id int             `json:"pharmacy_id"`
	Name        string          `json:"name"`
	Location    string          `json:"location"`
	Picture     string          `json:"picture"`
	Stock       []MedicineStock `json:"medicine"`
}

type MedicineStock struct {
	Medicine_id int    `json:"medicine_id"`
	Name        string `json:"name"`
	Price       int    `json:"price"`
	Quantity    int    `json:"quantity"`
	Barcode     string `json:"barcode"`
	Purpose     string `json:"purpose"`
}
