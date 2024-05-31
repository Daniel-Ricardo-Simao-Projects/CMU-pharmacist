import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_frontend/database/app_database.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/medicine_in_pharmacy.dart';
import '../models/medicine_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicineService {
  final String medicineURL =
      '${const String.fromEnvironment('URL', defaultValue: 'http://localhost:5000')}/medicines';
  final Dio dio = Dio();

  MedicineService();

  // To add a new medicine in a pharmacy
  Future<void> addMedicine(Medicine medicine) async {
    try {
      Map<String, dynamic> medicineJson = {
        'name': medicine.name,
        'stock': medicine.stock,
        'details': medicine.details,
        'picture': medicine.picture,
        'pharmacyId': medicine.pharmacyId,
        'barcode': medicine.barcode,
      };

      await dio.post(medicineURL, data: medicineJson);
    } catch (e) {
      rethrow;
    }
  }

  // To Show in the pharmacy panel
  Future<List<Medicine>> getMedicinesFromPharmacy(int pharmacyId) async {
    late List<MedicineInPharmacy> medicinesInPharmacy;
    List<Medicine> medicines = [];
    try {
      //TODO: Change URL
      final res = await dio
          .get('$medicineURL/from_pharmacy', data: {'pharmacyId': pharmacyId});

      medicinesInPharmacy = res.data['medicinesInPharmacy']
          .map<MedicineInPharmacy>(
            (item) => MedicineInPharmacy.fromJson(item),
          )
          .toList();

      List<int> medicineIdsNotCached = [];
      final database =
          await $FloorAppDatabase.databaseBuilder('app_database.db').build();
      for (var medicineInPharmacy in medicinesInPharmacy) {
        final medicine = await database.medicineDao
            .findMedicineById(medicineInPharmacy.medicineId);
        if (medicine == null) {
          medicineIdsNotCached.add(medicineInPharmacy.medicineId);
        } else {
          medicine.stock = medicineInPharmacy.stock;
          medicines.add(medicine);
        }
      }

      if (medicineIdsNotCached.isEmpty) {
        return medicines;
      }

      final newMedicines = await getMedicinesFromIds(medicineIdsNotCached);
      for (var newMedicine in newMedicines) {
        newMedicine.stock = medicinesInPharmacy
            .firstWhere((element) => element.medicineId == newMedicine.id)
            .stock;

        // Save image in file and register the path
        final fileName = '${newMedicine.name.replaceAll(' ', '_')}.jpg';
        final appDocDir = await getApplicationDocumentsDirectory();
        final file = File('${appDocDir.path}/$fileName');
        await file.writeAsBytes(base64Decode(newMedicine.picture));
        newMedicine.picture = file.path;

        medicines.add(newMedicine);
        await database.medicineDao.insertMedicine(newMedicine);
      }
      database.close();
    } catch (e) {
      medicinesInPharmacy = [];
    }

    return medicines;
  }

  // To fetch medicines given a list of ids
  Future<List<Medicine>> getMedicinesFromIds(List<int> medicineIds) async {
    late List<Medicine> medicines;
    try {
      //TODO: Maybe Change URL
      final res = await dio
          .get('$medicineURL/with_ids', data: {'medicineIds': medicineIds});

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
    late List<MedicineInPharmacy> pharmaciesWithMedicine;
    List<Pharmacy> pharmacies = [];
    try {
      // TODO: Change URL
      final res = await dio.get('$medicineURL/pharmaciesWithCache',
          data: {'medicineId': medicineId});

      pharmaciesWithMedicine = res.data['pharmacies']
          .map<MedicineInPharmacy>(
            (item) => MedicineInPharmacy.fromJson(item),
          )
          .toList();

      List<int> pharmacyIdsNotCached = [];
      final database =
          await $FloorAppDatabase.databaseBuilder('app_database.db').build();
      for (var pharmacyWithMedicine in pharmaciesWithMedicine) {
        final pharmacy = await database.pharmacyDao
            .findPharmacyById(pharmacyWithMedicine.pharmacyId);
        if (pharmacy == null) {
          pharmacyIdsNotCached.add(pharmacyWithMedicine.pharmacyId);
        } else {
          log("database: "+pharmacy.name);
          pharmacies.add(pharmacy);
        }
      }

      if (pharmacyIdsNotCached.isEmpty) {
        return pharmacies;
      }

      final newPharmacies = await getPharmaciesFromIds(pharmacyIdsNotCached);
      for (var newPharmacy in newPharmacies) {
        final fileName = '${newPharmacy.name.replaceAll(' ', '_')}.jpg';
        final appDocDir = await getApplicationDocumentsDirectory();
        final file = File('${appDocDir.path}/$fileName');
        await file.writeAsBytes(base64Decode(newPharmacy.picture));
        newPharmacy.picture = file.path;

        pharmacies.add(newPharmacy);
        await database.pharmacyDao.insertPharmacy(newPharmacy);
      }
      database.close();
    } catch (e) {
      pharmacies = [];
    }

    return pharmacies;
  }

  // To fetch pharmacies given a list of ids
  Future<List<Pharmacy>> getPharmaciesFromIds(List<int> pharmacyIds) async {
    late List<Pharmacy> pharmacies;
    try {
      // TODO: Change URL
      final res = await dio.get('$medicineURL/pharmaciesWithIds',
          data: {'pharmacyIds': pharmacyIds});

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
  Future<List<Pharmacy>> getPharmaciesFromSearch(String medicineInput, String coordinates) async {
    late List<Pharmacy> pharmacies;
    try {
      final res = await dio.get('$medicineURL/pharmacies-search',
          data: {'medicineInput': medicineInput, 'coordinates': coordinates});

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
      pharmacies = [];
    }
    return pharmacies;
  }

  // Get medicine given a barcode
  Future<Medicine> getMedicineFromBarcode(String barcode) async {
    late Medicine medicine;
    try {
      final res =
          await dio.get('$medicineURL/barcode', data: {'barcode': barcode});

      medicine = Medicine.fromJson(res.data['medicine']);
    } catch (e) {
      medicine = Medicine(
          id: 0,
          name: '',
          stock: 0,
          details: '',
          picture: '',
          pharmacyId: 0,
          barcode: '');
    }
    return medicine;
  }

  // To purchase a medicine
  void purchaseMedicine(int medicineId, int pharmacyId, int quantity) {
    try {
      dio.put('$medicineURL/purchase', data: {
        'medicineId': medicineId,
        'pharmacyId': pharmacyId,
        'quantity': quantity
      });
    } catch (e) {
      rethrow;
    }
  }

  // Add medicine to notifications
  Future<bool> addMedicineToNotifications(int medicineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        return false;
      }

      final response = await dio.post('$medicineURL/notifications/add', data: {
        'userId': username,
        'medicineId': medicineId,
      });

      if (response.statusCode == 201) {
        log("Medicine added to notifications");
        return true;
      } else {
        log("Failed to add medicine to notifications");
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Remove medicine from notifications
  Future<bool> removeMedicineFromNotifications(int medicineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        return false;
      }

      final response = await dio.delete('$medicineURL/notifications/remove',
          data: {'userId': username, 'medicineId': medicineId});

      if (response.statusCode == 200) {
        log("Medicine removed from notifications");
        return true;
      } else {
        log("Failed to remove medicine from notifications");
        return false;
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> isNotified(int medicineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null) {
        return false;
      }

      final response = await dio.get('$medicineURL/notifications/isNotified',
          data: {'userId': username, 'medicineId': medicineId});

      if (response.statusCode == 200) {
        // get boolean value from response
        bool isNotified = response.data['notified'];

        log("Is notified: $isNotified");

        return isNotified;
      } else {
        log("Failed to get notification status");

        return false;
      }
    } catch (e) {
      log(e.toString());

      return false;
    }
  }
}
