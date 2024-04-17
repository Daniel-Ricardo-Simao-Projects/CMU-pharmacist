package main

import (
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

type Product struct {
	Id          int    `json:"id"`
	Name        string `json:"name"`
	Price       int    `json:"price"`
	Description string `json:"description"`
}

var products = []Product{
	{100, "BassTune Headset 2.0", 200, "A headphone with a built-in high-quality microphone"},
	{101, "Fastlane Toy Car", 100, "A toy car that comes with a free HD camera"},
	{102, "ATV Gear Mouse", 75, "A high-quality mouse for office work and gaming"},
	{103, "BassTune Headset 1.0", 150, "A headphone with a built-in high-quality microphone"},
}

func getProductsHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"products": products})
}

func addProductHandler(c *gin.Context) {
	var newProduct Product
	if err := c.ShouldBindJSON(&newProduct); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	products = append(products, newProduct)
	c.JSON(http.StatusCreated, gin.H{"message": "Product added successfully"})
}

func updateProductHandler(c *gin.Context) {
	var updatedProduct Product
	if err := c.ShouldBindJSON(&updatedProduct); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	for i, p := range products {
		if p.Id == updatedProduct.Id {
			products[i] = updatedProduct
			c.JSON(http.StatusOK, gin.H{"message": "Product updated successfully"})
			return
		}
	}

	c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
}

func main() {
	r := gin.Default()
	r.Use(cors.Default())

	r.GET("/products", getProductsHandler)
	r.POST("/products", addProductHandler)
	r.PUT("/products/:id", updateProductHandler)

	r.Run(":5000")
}
