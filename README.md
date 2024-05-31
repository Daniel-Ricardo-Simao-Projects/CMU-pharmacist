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
    make addMed // adds Paracetamol to Pharmacy with id 1 ("Farmácia Alegro Montijo"). Helps debugging the notification feature.
```

To turn the connection secure between the backend and the flutter app, use cloudflare tunnel

```bash
    cloudflared tunnel --url http://localhost:5000
```
Or use your machine ip or router port forwarding ip, etc.

Copy the generated url to the flutter app explained below.

## Run flutter app

### Install Flutter

To run the flutter app, you need to have flutter installed. You can follow the instructions on the [official website](https://flutter.dev/docs/get-started/install).

### Firebase Configuration

Before running the app, you need to configure Firebase. You can follow the instructions down below or follow the instructions on the [official website](https://firebase.google.com/docs/flutter/setup).

1. Run the following command to install the Firebase CLI:

    ```bash
    curl -sL https://firebase.tools/ | bash
    ```

2. Run the following command to login to Firebase:

    ```bash
    firebase login
    ```

3. Export the service account key file to environment variables:

    ```bash
    export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/serviceAccountKey.json"
    ```

Note: For this to work, you need to either have your account connected to our project or create a new project and connect your account to it. If you are using our project, you can ask for the service account key file and to be added to the project.

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

If you want to run the app in a real phone instead of an emulator, run this code:

```bash
    adb reverse tcp:5000 tcp:5000
```


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
        - [x] The map is not refreshed when a marker is set (and/or in another cases)*
    - [x] Tapping a marker goes to a pharmacy information panel;
- [x] There should be an option to add a new pharmacy with:
    - [x] Name;
    - [x] Pick location 
        - [x] on map, 
        - [x] use address, or 
        - [x] current location;
    - [x] Take picture;
- [x] Find medicines (including at least a sub-string search), providing the closest pharmacy with the searched medicine;
    - [x] Search with a sub-string;
    - [x] Closest pharmacy is implemented;
- [x] Pharmacy Information Panel:
    - [x] Show name
    - [x] Show location. Button to navigate there;
    - [x] Show picture
    - [x] List available medicines;
    - [x] Button to add medicine stock (scan barcode)or create medicine if code unknown:
        - [x] Scan barcode;
        - [x] Name;
        - [x] Box photo (from camera or file);
        - [x] Quantity;
        - [x] Purpose/Preferred Use;
    - [x] Button to purchase/reduce stock (scan barcode);
    - [x] Button to add/remove from favorites;
    - [x] Tapping medicines opens medicine information panel;
- [x] Medicine Information Panel:
    - [x] Show name and picture;
    - [x] Button to get notification when available in favorite pharmacy;
    - [x] List pharmacies where available, sorted by distance.
        - [x] List pharmacies where available.
        - [x] Sorted by distance.
- [x] Do map directions

## Optional Features
- [x] Securing Communication;
- [x] User Ratings;
- [x] User Accounts;
- [x] UI Adaptability: Rotation;
- [x] UI Adaptability: Light/Dark Theme;
