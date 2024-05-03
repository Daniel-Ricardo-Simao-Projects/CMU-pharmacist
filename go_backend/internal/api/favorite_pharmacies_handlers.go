package handlers

import (
	"net/http"

	service "go_backend/internal/services"

	"github.com/gin-gonic/gin"
)

func GetFavoritePharmaciesHandler(c *gin.Context) {
	username := c.Param("username")

	pharmacies := service.GetFavoritePharmaciesByUsername(username)

	c.JSON(http.StatusOK, gin.H{"pharmacies": pharmacies})
}
