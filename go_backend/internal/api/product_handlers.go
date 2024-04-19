package handlers

import (
	"net/http"
	"strconv"

	db "go_backend/internal/database"
	models "go_backend/internal/models"

	"github.com/gin-gonic/gin"
)

func GetProductsHandler(c *gin.Context) {
	products := db.GetProducts()

	c.JSON(http.StatusOK, gin.H{"products": products})
}

func AddProductHandler(c *gin.Context) {
	var newProduct models.Product
	if err := c.ShouldBindJSON(&newProduct); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	db.AddProduct(newProduct)
	c.JSON(http.StatusCreated, gin.H{"message": "Product added successfully"})
}

func UpdateProductHandler(c *gin.Context) {
	var updatedProduct models.Product
	if err := c.ShouldBindJSON(&updatedProduct); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if db.UpdateProduct(updatedProduct) == nil {
		c.JSON(http.StatusOK, gin.H{"message": "Product updated successfully"})
		return
	}

	c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
}

func DeleteProductHandler(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid product ID"})
		return
	}

	if db.DeleteProduct(id) != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Product not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Product deleted successfully"})
}
