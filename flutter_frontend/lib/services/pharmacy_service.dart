import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pharmacy_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PharmacyService {
  String pharmaciesURL =
      '${const String.fromEnvironment('URL', defaultValue: 'http://localhost:5000')}/pharmacies';
  final Dio dio = Dio();

  PharmacyService();

  void getNewUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? httpUrl = prefs.getString('url');

    if (httpUrl != null) {
      pharmaciesURL = httpUrl + '/pharmacies';
    }
  }

  Future<void> addPharmacy(Pharmacy pharmacy) async {
    try {
      // Create JSON object with base64 string
      Map<String, dynamic> pharmacyJson = {
        'name': pharmacy.name,
        'address': pharmacy.address,
        'picture': pharmacy.picture,
        'latitude': pharmacy.latitude,
        'longitude': pharmacy.longitude,
      };
      getNewUrl();
      await dio.post(pharmaciesURL, data: pharmacyJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Pharmacy>> getPharmacies() async {
    late List<Pharmacy> pharmacies;
    try {
      log("GETTING PHARMACIES");
      getNewUrl();
      final res = await dio.get(pharmaciesURL);
      log('got response');
      pharmacies = res.data['pharmacies']
          .map<Pharmacy>(
            (item) => Pharmacy.fromJson(item),
          )
          .toList();

      for (var pharmacy in pharmacies) {
        final fileName = '${pharmacy.name.replaceAll(' ', '_')}.jpg';
        final appDocDir = await getApplicationDocumentsDirectory();
        final file = File('${appDocDir.path}/$fileName');
        await file.writeAsBytes(base64Decode(pharmacy.picture));
        pharmacy.picture = file.path;
      }
    } catch (e) {
      log(e.toString());
      // verbose error with stack trace
      throw e;
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
      getNewUrl();
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
      getNewUrl();
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
      getNewUrl();
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
      return [];
    }
    return favoritePharmaciesIds;
  }

  Future<bool> addPharmacyRating(int pharmacyId, int rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        return false;
      }
      getNewUrl();
      final response = await dio.post(
        '$pharmaciesURL/rating',
        data: {
          'username': username,
          'pharmacy_id': pharmacyId,
          'rating': rating
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<int> getPharmacyRatingByUser(int pharmacyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        return -1;
      }
      getNewUrl();
      final response = await dio.get(
        '$pharmaciesURL/rating',
        data: {'username': username, 'pharmacy_id': pharmacyId},
      );

      return response.data['rating'];
    } catch (e) {
      log(e.toString());
      return -1;
    }
  }

  Future<int> getPharmacyAverageRating(int pharmacyId) async {
    try {
      getNewUrl();
      final response = await dio.get(
        '$pharmaciesURL/rating/average',
        data: {'pharmacy_id': pharmacyId},
      );

      print(response.data['rating']);

      return response.data['rating'];
    } catch (e) {
      log(e.toString());
      return 0;
    }
  }

  Future<Map<int, int>> getPharmacyRatingHistogram(int pharmacyId) async {
    try {
      getNewUrl();
      final response = await dio.get(
        '$pharmaciesURL/rating/histogram',
        data: {'pharmacy_id': pharmacyId},
      );

      print(response.data['histogram']); // {1: 1, 2: 2, 3: 3, 4: 4, 5: 5}

      Map<int, int> histogram = {};
      for (var key in response.data['histogram'].keys) {
        histogram[int.parse(key)] = response.data['histogram'][key];
      }

      // print(histogram); // {1: 1, 2: 2, 3: 3, 4: 4, 5: 5}
      for (var key in histogram.keys) {
        print("$key: ${histogram[key]}");
      }

      return histogram;
    } catch (e) {
      log(e.toString());
      return {};
    }
  }
}
