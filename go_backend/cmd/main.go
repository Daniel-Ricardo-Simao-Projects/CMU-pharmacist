package main

import (
	api "go_backend/internal/api"
	config "go_backend/internal/config"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	config.ResetDatabase()

	r := gin.Default()
	r.Use(cors.Default())

	r.GET("/products", api.GetProductsHandler)
	r.POST("/products", api.AddProductHandler)
	r.PUT("/products/:id", api.UpdateProductHandler)
	r.DELETE("/products/:id", api.DeleteProductHandler)

	r.GET("/users", api.GetUsersHandler)
	r.POST("/users", api.AddUserHandler)
	r.PUT("/users/:id", api.UpdateUserHandler)
	r.DELETE("/users/:id", api.DeleteUserHandler)

	r.Run(":5000")
}
