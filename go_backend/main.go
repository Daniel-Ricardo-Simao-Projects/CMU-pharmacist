package main

import (
	api "go_backend/api"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.Use(cors.Default())

	r.GET("/products", api.GetProductsHandler)
	r.POST("/products", api.AddProductHandler)
	r.PUT("/products/:id", api.UpdateProductHandler)
	r.DELETE("/products/:id", api.DeleteProductHandler)

	r.Run(":5000")
}
