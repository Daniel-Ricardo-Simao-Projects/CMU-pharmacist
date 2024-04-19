package config

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"log"
)

const (
	dbDriver = "mysql"
	dbUser   = "root"
	dbPass   = <YOUR_PASSWORD>
	dbName   = "pharmacist_app"
)

func OpenDB() (*sql.DB, error) {
	db, err := sql.Open(dbDriver, dbUser+":"+dbPass+"@/"+dbName)
	if err != nil {
		return nil, err
	}
	return db, nil
}

func CloseDB(db *sql.DB) {
	db.Close()
}

func ResetDatabase() {
	db, err := sql.Open(dbDriver, dbUser+":"+dbPass+"@/")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	_, err = db.Exec("DROP DATABASE IF EXISTS " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec("CREATE DATABASE " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec("USE " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	_, err = db.Exec(`CREATE TABLE products (
		id INT AUTO_INCREMENT PRIMARY KEY,
		name VARCHAR(100) NOT NULL,
		price INT,
		description TEXT
	)`)
	if err != nil {
		log.Fatal(err)
	}
}
