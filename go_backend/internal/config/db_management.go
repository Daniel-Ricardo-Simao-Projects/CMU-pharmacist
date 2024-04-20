package config

import (
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"log"
	"os"
)

const (
	dbDriver = "mysql"
	dbUser   = "root"
	dbPass   = "1710Fedora"
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

	// Open SQL file
	file, err := os.Open("internal/config/database_schema.sql")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	// Read SQL file
	stat, err := file.Stat()
	if err != nil {
		log.Fatal(err)
	}
	fileSize := stat.Size()
	buffer := make([]byte, fileSize)
	_, err = file.Read(buffer)
	if err != nil {
		log.Fatal(err)
	}

	// Execute SQL statements
	_, err = db.Exec(string(buffer))
	if err != nil {
		log.Fatal(err)
	}
}
