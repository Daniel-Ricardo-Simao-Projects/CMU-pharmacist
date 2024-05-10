package database

import (
	_ "github.com/go-sql-driver/mysql"
	"log"

	config "go_backend/internal/config"
	models "go_backend/internal/models"
)

func GetUserInfoByUsername(username string) *models.User {
	row := config.DB.QueryRow("SELECT * FROM users WHERE username = ?", username)

	var userInfo models.User
	err := row.Scan(&userInfo.Id, &userInfo.Username, &userInfo.Password)
	if err != nil {
		return nil
	}

	return &userInfo
}

func GetUserByUsername(username string) *models.User {
	row := config.DB.QueryRow("SELECT * FROM users WHERE username = ?", username)

	var user models.User
	err := row.Scan(&user.Id, &user.Username, &user.Password)
	if err != nil {
		return nil
	}

	return &user
}

func GetUserById(id int) *models.User {
	row := config.DB.QueryRow("SELECT * FROM users WHERE id = ?", id)

	var user models.User
	err := row.Scan(&user.Id, &user.Username, &user.Password)
	if err != nil {
		return nil
	}

	return &user
}

func AddUser(user models.User) {
	_, err := config.DB.Exec("INSERT INTO users (username, password) VALUES (?, ?)", user.Username, user.Password)
	if err != nil {
		log.Fatal(err)
	}
}

func UpdateUser(user models.User) error {
	_, err := config.DB.Exec("UPDATE users SET username = ?, password = ? WHERE id = ?", user.Username, user.Password, user.Id)
	if err != nil {
		return err
	}

	return nil
}

func DeleteUser(id int) error {
	_, err := config.DB.Exec("DELETE FROM users WHERE id = ?", id)
	if err != nil {
		return err
	}

	return nil
}

func GetUsers() []models.User {
	rows, err := config.DB.Query("SELECT * FROM users")
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
