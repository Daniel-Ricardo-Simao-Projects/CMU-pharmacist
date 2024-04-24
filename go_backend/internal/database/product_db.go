package database

import (
	_ "github.com/go-sql-driver/mysql"
	"log"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
)

func AddProduct(product models.Product) {
	_, err := config.DB.Exec("INSERT INTO products (name, price, description) VALUES (?, ?, ?)", product.Name, product.Price, product.Description)
	if err != nil {
		log.Fatal(err)
	}
}

func UpdateProduct(product models.Product) error {
	_, err := config.DB.Exec("UPDATE products SET name = ?, price = ?, description = ? WHERE id = ?", product.Name, product.Price, product.Description, product.Id)
	if err != nil {
		return err
	}

	return nil
}

func DeleteProduct(id int) error {
	_, err := config.DB.Exec("DELETE FROM products WHERE id = ?", id)
	if err != nil {
		return err
	}

	return nil
}

func GetProducts() []models.Product {
	rows, err := config.DB.Query("SELECT * FROM products")
	if err != nil {
		log.Fatal(err)
	}

	products := []models.Product{}
	for rows.Next() {
		var product models.Product
		err := rows.Scan(&product.Id, &product.Name, &product.Price, &product.Description)
		if err != nil {
			log.Fatal(err)
		}
		products = append(products, product)
	}

	return products
}
