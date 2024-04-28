import 'dart:developer';

import 'package:dio/dio.dart';
import '../models/user_model.dart';

class UserService {
  final String usersURL = 'http://localhost:5000/users';
  final Dio dio = Dio();

  UserService();

  Future<void> addUser(User user) async {
    try {
      // Create JSON object with base64 string
      Map<String, dynamic> userJson = {
        'name': user.name,
        'password': user.password,
      };

      await dio.post(usersURL, data: userJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> authenticateUser(String username, String password) async {
    try {
      // Create JSON object with username and password
      Map<String, dynamic> userData = {
        'username': username,
        'password': password,
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
