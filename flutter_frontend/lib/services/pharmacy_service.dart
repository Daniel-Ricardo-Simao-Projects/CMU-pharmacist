import 'dart:developer';

import 'package:dio/dio.dart';
import '../models/pharmacy_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PharmacyService {
  final String pharmaciesURL =
      '${const String.fromEnvironment('URL', defaultValue: 'http://localhost:5000')}/pharmacies';
  final Dio dio = Dio();

  PharmacyService();

  Future<void> addPharmacy(Pharmacy pharmacy) async {
    try {
      // Convert List<int> to base64 string
      String pictureBase64 = base64Encode(pharmacy.picture);

      // Create JSON object with base64 string
      Map<String, dynamic> pharmacyJson = {
        'name': pharmacy.name,
        'address': pharmacy.address,
        'picture': pictureBase64,
      };

      await dio.post(pharmaciesURL, data: pharmacyJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Pharmacy>> getPharmacies() async {
    late List<Pharmacy> pharmacies;
    try {
      log("GETTING PHARMACIES");
      final res = await dio.get(pharmaciesURL);
      log('got response');
      pharmacies = res.data['pharmacies']
          .map<Pharmacy>(
            (item) => Pharmacy.fromJson(item),
          )
          .toList();
    } catch (e) {
      // verbose error with stack trace
      pharmacies = [];
    }
    return pharmacies;
  }

  // add pharmacy to favorite pharmacies
  Future<bool> addFavoritePharmacy(int pharmacyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        return false;
      }

      final response = await dio.post(
        '$pharmaciesURL/favoriteadd',
        data: {'userId': username, 'pharmacyId': pharmacyId},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> removeFavoritePharmacy(int pharmacyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        log('Username not found');
        return false;
      }

      final response = await dio.delete(
        '$pharmaciesURL/favoritedelete',
        data: {'userId': username, 'pharmacyId': pharmacyId},
      );

      if (response.statusCode == 200) {
        log('Pharmacy removed from favorites');
        return true;
      } else {
        log('Failed to remove pharmacy from favorites');
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<List<int>> getFavoritePharmaciesIds() async {
    late List<int> favoritePharmaciesIds;
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        return [];
      }

      final response = await dio.get(
        '$pharmaciesURL/favoriteget',
        data: {'userId': username},
      );

      // get list of favorite pharmacies
      List<Pharmacy> pharmacies = response.data['pharmacies']
          .map<Pharmacy>(
            (item) => Pharmacy.fromJson(item),
          )
          .toList();

      favoritePharmaciesIds =
          pharmacies.map((pharmacy) => pharmacy.id).toList();
    } catch (e) {
      log(e.toString());
    }
    return favoritePharmaciesIds;
  }
}
