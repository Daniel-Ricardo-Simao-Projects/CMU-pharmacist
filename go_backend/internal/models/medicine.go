package models

type Medicine struct {
	Id         int    `json:"id"`
	Name       string `json:"name"`
	Details    string `json:"details"`
	Picture    string `json:"picture"`
	Stock      int    `json:"stock"`
	PharmacyId int    `json:"pharmacyId"`
  Barcode    string `json:"barcode"`
}

type MedicineFromPharmacy struct {
  MedicineId int `json:"medicineId"`
  PharmacyId int `json:"pharmacyId"`
  Stock      int `json:"stock"`
}
