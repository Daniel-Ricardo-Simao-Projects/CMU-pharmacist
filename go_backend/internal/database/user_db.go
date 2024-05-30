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

func GetUserIdByUsername(username string) int {
	row := config.DB.QueryRow("SELECT id FROM users WHERE username = ?", username)

	var id int
	err := row.Scan(&id)
	if err != nil {
		return -1
	}

	return id
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

func AddFCMToken(username, token string) error {
	// check if entry exists. If exists, update the token
	row := config.DB.QueryRow("SELECT * FROM fcm_tokens WHERE user_id = ?", GetUserIdByUsername(username))

	var userToken string

	err := row.Scan(&userToken, &token)
	if err == nil {
		println("Token exists. Updating token")
		return UpdateFCMToken(username, token)
	}

	println("Token does not exist", &token)

	_, err = config.DB.Exec("INSERT INTO fcm_tokens (user_id, token) VALUES (?, ?)", GetUserIdByUsername(username), token)
	if err != nil {
		log.Fatal(err)
		return err
	}

	return nil
}

func UpdateFCMToken(username, token string) error {
	userId := GetUserIdByUsername(username)

	_, err := config.DB.Exec("UPDATE fcm_tokens SET token = ? WHERE user_id = ?", token, userId)
	if err != nil {
		log.Fatal(err)
		return err
	}

	return nil
}

func GetTokenByUserId(userId int) string {
	row := config.DB.QueryRow("SELECT token FROM fcm_tokens WHERE user_id = ?", userId)

	var token string
	err := row.Scan(&token)
	if err != nil {
		return ""
	}

	return token
}
