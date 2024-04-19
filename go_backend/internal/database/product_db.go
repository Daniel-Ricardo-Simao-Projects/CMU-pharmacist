package database

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"log"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
)

var db *sql.DB

func AddProduct(product models.Product) {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	_, err = db.Exec("INSERT INTO products (name, price, description) VALUES (?, ?, ?)", product.Name, product.Price, product.Description)
	if err != nil {
		log.Fatal(err)
	}
}

func UpdateProduct(product models.Product) error {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	_, err = db.Exec("UPDATE products SET name = ?, price = ?, description = ? WHERE id = ?", product.Name, product.Price, product.Description, product.Id)
	if err != nil {
		return err
	}

	return nil
}

func DeleteProduct(id int) error {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	_, err = db.Exec("DELETE FROM products WHERE id = ?", id)
	if err != nil {
		return err
	}

	return nil
}

func GetProducts() []models.Product {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	rows, err := db.Query("SELECT * FROM products")
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
