import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';

class UserService {
  final String usersURL =
      '${const String.fromEnvironment('URL', defaultValue: 'http://localhost:5000')}/users';
  final Dio dio = Dio();
  late User
      user; // user object to store the authenticated user and access it throughout the app

  UserService();

  // getter to access the authenticated user
  User getUser() {
    log(user.toString());
    return user;
  }

  Future<bool> addUser(String username, String password) async {
    try {
      String hashedPassword = sha256.convert(utf8.encode(password)).toString();

      Map<String, dynamic> userJson = {
        'username': username,
        'password': hashedPassword,
      };

      final response = await dio.post(usersURL, data: userJson);

      if (response.statusCode == 201) {
        log('User added successfully');
        return true;
      } else {
        log('Failed to add user');
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> authenticateUser(
      String username, String password, String? fcmToken) async {
    try {
      String hashedPassword = sha256.convert(utf8.encode(password)).toString();

      // Create JSON object with username and password
      Map<String, dynamic> userData = {
        'username': username,
        'password': hashedPassword,
        'fcm_token': fcmToken,
      };

      final response = await dio.post('$usersURL/authenticate', data: userData);

      // Check if the response contains a message indicating successful authentication
      if (response.statusCode == 200) {
        log("User authenticated successfully${response.data}");
        user = User.fromJsonWithoutLastAttribute(response.data);
        saveUser(user);
        // Store the authenticated user in the user object
        // User authenticated successfully
        return true;
      } else {
        // Authentication failed
        return false;
      }
    } catch (e) {
      // Handle any errors that occur during the authentication process
      log(e.toString());
      return false;
    }
  }

  void updateFcmToken(String? fcmToken) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');
      if (username != null) {
        Map<String, dynamic> userData = {
          'username': username,
          'fcm_token': fcmToken,
        };

        log("Updating FCM token :$fcmToken for user: $username");

        final response = await dio.put('$usersURL/token', data: userData);
        if (response.statusCode == 200) {
          log("FCM token updated successfully");
        } else {
          log("Failed to update FCM token");
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');

    // clear also the db
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

    final userDao = database.userDao;
    final user = await userDao.findLoggedInUser();
    if (user != null) {
      user.isLogged = false;
      await userDao.updateUser(user);
    }

    log("User logged out");
  }

  Future<void> saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id.toString());
    await prefs.setString('username', user.name);
  }
}
