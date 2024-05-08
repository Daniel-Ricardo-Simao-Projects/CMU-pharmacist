import 'dart:developer';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserService {
  final String usersURL = '${const String.fromEnvironment('URL', defaultValue: 'http://localhost:5000')}/users';
  final Dio dio = Dio();

  UserService();

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

  Future<bool> authenticateUser(String username, String password) async {
    try {
      String hashedPassword = sha256.convert(utf8.encode(password)).toString();

      // Create JSON object with username and password
      Map<String, dynamic> userData = {
        'username': username,
        'password': hashedPassword,
      };

      final response = await dio.post('$usersURL/authenticate', data: userData);

      // Check if the response contains a message indicating successful authentication
      if (response.statusCode == 200 &&
          response.data['message'] == "User authenticated successfully") {
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
}
