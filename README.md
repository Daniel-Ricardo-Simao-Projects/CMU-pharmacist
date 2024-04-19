# PharmacIST
PharmacIST is an Android mobile application designed to simplify medication management for both you and your local pharmacies. Developed as part of the Mobile and Ubiquitous Computation course at IST (2023-2024)

## Stack
- Database: ?
- Backend: Go
- Frontend: Flutter

## Install and Setup Database
1. We use MySQL as our database. Install the community edition from the [official website](https://dev.mysql.com/downloads/mysql/).
2. Run the following command to enable the MySQL service:
    ```bash
    sudo systemctl enable mysqld
    ```
3. Run the following command to start the MySQL service:
    ```bash
    sudo service mysqld start
    ```
4. Run the following command to configure the MySQL service:
    ```bash
    sudo mysql_secure_installation
    ```
5. Run the following commands to confirm the installation and login to the MySQL shell:
    ```bash
    mysql --version
    mysql -u root -p
    ```
If the version is displayed (we are using 8.0.35) and you are able to login to the MySQL shell, the installation was successful.

Then you have to change the database configuration in the backend to match your MySQL configuration. The configuration file is located at `go_backend/config/config.go`. Change the following lines:
```go
    const (
        dbDriver = "mysql"
        dbUser   = "root"
        dbPass   = <YOUR_PASSWORD>
        dbName   = "pharmacist_app"
    )
```
Where `<YOUR_PASSWORD>` is the password you set during the MySQL installation.
With the database configuration set, you can now run the backend with the following command (assuming you are in the main directory):
```bash
    cd go_backend
    make run
```

## Mandatory Features
- [ ] Allow users to create a username in the application/system.
- [ ] Show a map with pharmacy locations:
    - [ ] The map can be dragged, address searched, or centered on current location;
    - [ ] Favorite pharmacies have a different marker;
    - [ ] Tapping a marker goes to a pharmacy information panel;
- [ ] There should be an option to add a new pharmacy with:
    - [ ] Name;
    - [ ] Pick location on map, use address, or current location;
    - [ ] Take picture;
- [ ] Find medicines (including at least a sub-string search), providing the closest pharmacy with the searched medicine;
- [ ] Pharmacy Information Panel:
    - [ ] Show name, location on map, and picture. Button to navigate there;
    - [ ] List available medicines;
    - [ ] Button to add medicine stock (scan barcode)or create medicine if code unknown:
        - [ ] Name;
        - [ ] Box photo (from camera or file);
        - [ ] Quantity;
        - [ ] Purpose/Preferred Use;
    - [ ] Button to purchase/reduce stock (scan barcode);
    - [ ] Button to add/remove from favorites;
    - [ ] Tapping medicines opens medicine information panel;
- [ ] Medicine Information Panel:
    - [ ] Show name and picture;
    - [ ] Button to get notification when available in favorite pharmacy;
    - [ ] List pharmacies where available, sorted by distance.

## Optional Features
- [ ] Securing Communication;
- [ ] Meta Moderation;
- [ ] User Ratings;
- [ ] User Accounts;
- [ ] Social Sharing To Other Apps;
- [ ] Localization (L10n);
- [ ] UI Adaptability: Rotation;
- [ ] UI Adaptability: Light/Dark Theme;
- [ ] Recommendations;

## TODO
