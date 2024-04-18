package handlers

import (
	"net/http"
	"strconv"

	models "go_backend/models"

	"github.com/gin-gonic/gin"
)

var products = []models.Product{
	{100, "BassTune Headset 2.0", 200, "A headphone with a built-in high-quality microphone"},
	{101, "Fastlane Toy Car", 100, "A toy car that comes with a free HD camera"},
	{102, "ATV Gear Mouse", 75, "A high-quality mouse for office work and gaming"},
	{103, "BassTune Headset 1.0", 150, "A headphone with a built-in high-quality microphone"},
}

func GetProductsHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"products": products})
}

func AddProductHandler(c *gin.Context) {
	var newProduct models.Product
	if err := c.ShouldBindJSON(&newProduct); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	products = append(products, newProduct)
	c.JSON(http.StatusCreated, gin.H{"message": "Product added successfully"})
}

func UpdateProductHandler(c *gin.Context) {
	var updatedProduct models.Product
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

func DeleteProductHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid product ID"})
		return
	}

	index := -1
	for i, p := range products {
		if p.Id == id {
			index = i
			break
		}
	}

	if index == -1 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
		return
	}

	products = append(products[:index], products[index+1:]...)
	c.JSON(http.StatusOK, gin.H{"message": "Product deleted successfully"})
}
