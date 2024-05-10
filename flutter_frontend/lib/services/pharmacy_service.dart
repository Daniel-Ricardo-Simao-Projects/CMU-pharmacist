import 'dart:developer';

import 'package:dio/dio.dart';
import '../models/pharmacy_model.dart';
import 'dart:convert';

class PharmacyService {
  final String pharmaciesURL = '${const String.fromEnvironment('URL', defaultValue: 'http://localhost:5000')}/pharmacies';
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
      log(e.toString());
      pharmacies = [];
    }
    return pharmacies;
  }
}
