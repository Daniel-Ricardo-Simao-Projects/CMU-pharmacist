package main

import (
	"encoding/base64"
	handlers "go_backend/internal/api"
	config "go_backend/internal/config"
	models "go_backend/internal/models"
	"log"
	"os"
)

func main() {
	if err := config.OpenDB(); err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB()

	medicinePicture, err := os.ReadFile("internal/images/stock_photos/paracetamol.png")
	if err != nil {
		log.Fatal(err)
	}
	picture := base64.StdEncoding.EncodeToString(medicinePicture)

	var medicine = models.Medicine{
		Id:         0,
		Name:       "Paracetamol",
		Details:    "Paracetamol is a pain reliever and a fever reducer. The exact mechanism of action of is not known. Paracetamol is used to treat many conditions such as headache, muscle aches, arthritis, backache, toothaches, colds, and fevers. It relieves pain in mild arthritis but has no effect on the underlying inflammation and swelling of the joint.",
		Stock:      100,
		PharmacyId: 1,
		Picture:    picture,
		Barcode:    "1234567890123",
	}

	handlers.AddMedicineHandlerUtils(medicine)
}
