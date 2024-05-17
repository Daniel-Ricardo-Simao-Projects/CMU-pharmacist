package main

import (
	api "go_backend/internal/api"
	config "go_backend/internal/config"
	"log"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	if err := config.OpenDB(); err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB()

	//gin.SetMode(gin.ReleaseMode)

	r := gin.Default()
	r.Use(cors.Default())

	r.GET("/products", api.GetProductsHandler)
	r.POST("/products", api.AddProductHandler)
	r.PUT("/products/:id", api.UpdateProductHandler)
	r.DELETE("/products/:id", api.DeleteProductHandler)

	r.GET("/users", api.GetUsersHandler)
	r.POST("/users/authenticate", api.AuthenticateUserHandler)
	r.POST("/users", api.AddUserHandler)
	r.PUT("/users/:id", api.UpdateUserHandler)
	r.DELETE("/users/:id", api.DeleteUserHandler)

	r.GET("/pharmacies", api.GetPharmacyHandler)
	r.POST("/pharmacies", api.AddPharmacyHandler)

	r.GET("/medicines", api.GetMedicineHandler)
	r.POST("/medicines", api.AddMedicineHandler)
  r.GET("/medicines/barcode", api.GetMedicineFromBarcodeHandler)
	r.GET("/medicines/pharmacies", api.GetPharmacyWithMedicineHandler)
	r.GET("/medicines/pharmacies-search", api.SearchPharmacyWithMedicineHandler)

	r.GET("/pharmacies/favoriteget", api.GetFavoritePharmaciesHandler)
	r.POST("/pharmacies/favoriteadd", api.AddFavoritePharmacyHandler)
	r.DELETE("/pharmacies/favoritedelete", api.RemoveFavoritePharmacyHandler)

	r.Run(":5000")
}
