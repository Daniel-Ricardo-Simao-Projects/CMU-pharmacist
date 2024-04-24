package database

import (
	_ "github.com/go-sql-driver/mysql"
	"log"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
)

func GetUserByUsername(username string) *models.User {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	row := db.QueryRow("SELECT * FROM users WHERE username = ?", username)

	var user models.User
	err = row.Scan(&user.Id, &user.Username, &user.Password)
	if err != nil {
		return nil
	}

	return &user
}

func AddUser(user models.User) {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	_, err = db.Exec("INSERT INTO users (username, password) VALUES (?, ?)", user.Username, user.Password)
	if err != nil {
		log.Fatal(err)
	}
}

func UpdateUser(user models.User) error {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	_, err = db.Exec("UPDATE users SET username = ?, password = ? WHERE id = ?", user.Username, user.Password, user.Id)
	if err != nil {
		return err
	}

	return nil
}

func DeleteUser(id int) error {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	_, err = db.Exec("DELETE FROM users WHERE id = ?", id)
	if err != nil {
		return err
	}

	return nil
}

func GetUsers() []models.User {
	db, err := config.OpenDB()
	if err != nil {
		log.Fatal(err)
	}
	defer config.CloseDB(db)

	rows, err := db.Query("SELECT * FROM users")
	if err != nil {
		log.Fatal(err)
	}

	users := []models.User{}
	for rows.Next() {
		var user models.User
		err := rows.Scan(&user.Id, &user.Username, &user.Password)
		if err != nil {
			log.Fatal(err)
		}
		users = append(users, user)
	}

	return users
}
