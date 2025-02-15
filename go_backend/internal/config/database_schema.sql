CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL
);

CREATE TABLE pharmacies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(255) DEFAULT NULL,
  image_path VARCHAR(255) DEFAULT NULL,
  latitude DECIMAL(9, 6) DEFAULT NULL,
  longitude DECIMAL(9, 6) DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medicines (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  details TEXT NOT NULL,
  image_path VARCHAR(255) DEFAULT NULL,
  barcode VARCHAR(255) DEFAULT NULL
);

CREATE TABLE medicine_pharmacy (
  medicine_id INT NOT NULL,
  pharmacy_id INT NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  FOREIGN KEY (medicine_id) REFERENCES medicines(id),
  FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id),
  PRIMARY KEY (medicine_id, pharmacy_id)
);

CREATE TABLE favorites (
  user_id INT NOT NULL,
  pharmacy_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id),
  PRIMARY KEY (user_id, pharmacy_id)
);

CREATE TABLE notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  medicine_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (medicine_id) REFERENCES medicines(id)
);

CREATE TABLE fcm_tokens (
  user_id INT NOT NULL,
  token VARCHAR(255) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  PRIMARY KEY (user_id, token)
);

CREATE TABLE pharmacy_ratings (
    user_id INT NOT NULL,
    pharmacy_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(id),
    PRIMARY KEY (user_id, pharmacy_id)
);
