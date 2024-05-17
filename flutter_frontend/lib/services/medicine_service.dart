import 'package:dio/dio.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import '../models/medicine_model.dart';
import 'dart:convert';

class MedicineService {
  final String medicineURL =
      '${const String.fromEnvironment('URL', defaultValue: 'http://localhost:5000')}/medicines';
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
        'barcode': medicine.barcode,
      };

      await dio.post(medicineURL, data: medicineJson);
    } catch (e) {
      rethrow;
    }
  }

  // TODO: Review if it is necessary to add barcode specification/implementation down here
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

  // To show in the medicine panel
  Future<List<Pharmacy>> getPharmaciesWithMedicine(int medicineId) async {
    late List<Pharmacy> pharmacies;
    try {
      final res = await dio
          .get('$medicineURL/pharmacies', data: {'medicineId': medicineId});

      pharmacies = res.data['pharmacies']
          .map<Pharmacy>(
            (item) => Pharmacy.fromJson(item),
          )
          .toList();
    } catch (e) {
      pharmacies = [];
    }
    return pharmacies;
  }

  // To get the pharmacies from the search menu, given a medicine substring
  Future<List<Pharmacy>> getPharmaciesFromSearch(String medicineInput) async {
    late List<Pharmacy> pharmacies;
    try {
      final res = await dio.get('$medicineURL/pharmacies-search',
          data: {'medicineInput': medicineInput});

      pharmacies = res.data['pharmacies']
          .map<Pharmacy>(
            (item) => Pharmacy.fromJson(item),
          )
          .toList();
    } catch (e) {
      pharmacies = [];
    }
    return pharmacies;
  }

  // Get medicine given a barcode
  Future<Medicine> getMedicineFromBarcode(String barcode) async {
    late Medicine medicine;
    try {
      final res = await dio.get('$medicineURL/barcode', data: {'barcode': barcode});

      medicine = Medicine.fromJson(res.data['medicine']);
    } catch (e) {
      medicine = const Medicine(id: 0, name: '', stock: 0, details: '', picture: [], pharmacyId: 0, barcode: '');
    }
    return medicine;
  }

  // TODO: Maybe add a new method to update the stock of a medicine
}
