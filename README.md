# PharmacIST
PharmacIST is an Android mobile application designed to simplify medication management for both you and your local pharmacies. Developed as part of the Mobile and Ubiquitous Computation course at IST (2023-2024)

## Stack
- Database: MySQL 
- Backend: Go
- Frontend: Flutter

## Install and Setup Database
1. We use MySQL (version 8.0.35) as our database. Install the community edition from the [official website](https://dev.mysql.com/downloads/mysql/).
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
If the version is displayed and you are able to login to the MySQL shell, the installation was successful.

Then you have to change the database configuration in the backend to match your MySQL configuration. The configuration file is located at `go_backend/config/db_management.go`. It uses an `.env` file that must be located in the project root directory. Create it with the following variables. Change the password line to match your MySQL password. If you created another user, change the user line as well. The default configuration is as follows:

```bash
    DB_DRIVER="mysql"
    DB_USER="root"
    DB_PASS=<YOUR_PASSWORD>
    DB_NAME="pharmacist_app"

```

```go
    const (
        dbName   = "pharmacist_app"
    )
```
Where `<YOUR_PASSWORD>` is the password you set during the MySQL installation.

## Run the backend

### Install Go

To run the backend, you need to have Go installed. You can follow the instructions on the [official website](https://golang.org/doc/install).

### Run the backend

With the database configuration set, you can now run the backend with the following command (assuming you are in the main directory):

```bash
    cd go_backend
    make run
```

Besides that, if you want, before running the backend, you can populate or clean the database with the following commands:

```go
    make seed // populate the database
    make drop // clean the database
```

## Run flutter app

### Install Flutter

To run the flutter app, you need to have flutter installed. You can follow the instructions on the [official website](https://flutter.dev/docs/get-started/install).

### Run the app

After the backend is running, you can run the flutter app with the following command (assuming you are in the main directory):

```bash
    cd flutter_frontend
    flutter run
```

You can also define a different backend url with the command in case you are running the backend in a different machine or port.

```bash
    flutter run --dart-define=URL=<BACKEND_URL>:5000
```

The default URL is localhost:5000.


### Insert google maps API key

You need to place the API key in the flutter app for the map to run.

In AndroidManifest.xml, add the API key here:

```xml
    <meta-data 
        android:name="com.google.android.geo.API_KEY"
        android:value="ADD-API-KEY-HERE"
    />
```
In constants.dart, add here:

```dart 
    const String apiKey = "API_KEY";
```

## Mandatory Features
- [x] Allow users to create a username in the application/system.
- [x] Show a map with pharmacy locations:
    - [x] The map can be dragged or centered on current location;
    - [x] Search for pharmacy given the address
    - [x] Favorite pharmacies have a different marker;
        - [ ] *Note: fix this, the map is not refreshed when a marker is set (and/or in another cases)*
    - [x] Tapping a marker goes to a pharmacy information panel;
- [ ] There should be an option to add a new pharmacy with:
    - [x] Name;
    - [ ] Pick location 
        - [ ] on map, 
        - [x] use address, or 
        - [x] current location;
        - *Note: location is just a string, no map integration yet.*
    - [x] Take picture;
- [ ] Find medicines (including at least a sub-string search), providing the closest pharmacy with the searched medicine;
    - [x] Search with a sub-string;
    - [ ] *Note: Closest pharmacy is not implemented yet.*
    - [ ] *Note: fix performance issue, maybe fetch only the first 10 results and load more on demand/render only a subset*
- [ ] Pharmacy Information Panel:
    - [x] Show name
    - [ ] Show location. Button to navigate there;
        - *Note: location is just a string, no map integration yet.*
    - [x] Show picture
    - [x] List available medicines;
    - [x] Button to add medicine stock (scan barcode)or create medicine if code unknown:
        - [x] Scan barcode
            - [ ] *Note: Now is mandatory to scan barcodes, **maybe** add manual input*
        - [x] Name;
        - [x] Box photo (from camera or file);
        - [x] Quantity;
        - [x] Purpose/Preferred Use;
    - [x] Button to purchase/reduce stock (scan barcode);
    - [x] Button to add/remove from favorites;
    - [x] Tapping medicines opens medicine information panel;
- [ ] Medicine Information Panel:
    - [x] Show name and picture;
    - [x] Button to get notification when available in favorite pharmacy;
        - [ ] *Maybe Extra: When clicking the notification, go to the right pharmacy*
    - [ ] List pharmacies where available, sorted by distance.
        - [x] List pharmacies where available.
        - [ ] *Note: Sorted by distance.*
- [ ] Do map directions ?????

## Optional Features
- [ ] Securing Communication;
- [ ] Meta Moderation;
- [ ] User Ratings;
- [ ] User Accounts;
- [ ] Social Sharing To Other Apps;
- [ ] Localization (L10n);
- [x] UI Adaptability: Rotation; *Note: **Maybe** done, automagically*
- [ ] UI Adaptability: Light/Dark Theme;
- [ ] Recommendations;

## TODO
