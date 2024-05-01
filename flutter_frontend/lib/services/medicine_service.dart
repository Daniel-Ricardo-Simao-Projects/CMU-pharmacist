import 'package:dio/dio.dart';
import '../models/medicine_model.dart';
import 'dart:convert';

class MedicineService {
  final String medicineURL = 'http://localhost:5000/medicines';
  final Dio dio = Dio();

  MedicineService();

  // To add a new medicine in a pharmacy
  Future<void> addMedicine(Medicine medicine) async {
    try {
      String pictureBase64 = base64Encode(medicine.picture);

      Map<String, dynamic> medicineJson = {
        'name': medicine.name,
        'stock': medicine.stock,
        'details': medicine.details,
        'picture': pictureBase64,
        'pharmacyId': medicine.pharmacyId,
      };

      await dio.post(medicineURL, data: medicineJson);
    } catch (e) {
      rethrow;
    }
  }

  // To Show in the pharmacy panel
  Future<List<Medicine>> getMedicinesFromPharmacy(int pharmacyId) async {
    late List<Medicine> medicines;
    try {
      final res = await dio.get(medicineURL, data: {'pharmacyId': pharmacyId});

      medicines = res.data['medicines']
          .map<Medicine>(
            (item) => Medicine.fromJson(item),
          )
          .toList();
    } catch (e) {
      medicines = [];
    }
    return medicines;
  }

  // TODO: Maybe add a new method to update the stock of a medicine
}
