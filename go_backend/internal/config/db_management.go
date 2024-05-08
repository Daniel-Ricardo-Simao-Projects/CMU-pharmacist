package config

import (
	"database/sql"

	//"go_backend/internal/database"
	"os"

	_ "github.com/go-sql-driver/mysql" // MySQL driver

	"github.com/joho/godotenv"
	"github.com/tanimutomo/sqlfile"

	"log"
)

const (
	dbName = "pharmacist_app"
)

var DB *sql.DB

func OpenDB() error {
	if err := godotenv.Load("../.env"); err != nil {
		log.Fatal("Error loading .env file")
	}

	dbDriver := os.Getenv("DB_DRIVER")
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASS")

	var err error
	DB, err = sql.Open(dbDriver, dbUser+":"+dbPass+"@/"+dbName)
	if err != nil {
		return err
	}
	return nil
}

func CloseDB() error {
	if err := DB.Close(); err != nil {
		return err
	}
	return nil
}

func ResetDatabase() {
	var err error
	_, err = DB.Exec("DROP DATABASE IF EXISTS " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	_, err = DB.Exec("CREATE DATABASE " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	_, err = DB.Exec("USE " + dbName)
	if err != nil {
		log.Fatal(err)
	}

	s := sqlfile.New()
	err = s.File("internal/config/database_schema.sql")
	if err != nil {
		log.Fatal(err)
	}

	_, err = s.Exec(DB)
	if err != nil {
		log.Fatal(err)
	}
	RemoveImagesDir()
}
