import 'package:dio/dio.dart';
import 'package:flutter_frontend/database/app_database.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import '../models/medicine_in_pharmacy.dart';
import '../models/medicine_model.dart';

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
  // TODO: Delete this method
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

  // To show in the pharmacy panel
  Future<List<Medicine>> getMedicinesFromPharmacyWithCache(
      int pharmacyId) async {
    late List<MedicineInPharmacy> medicinesInPharmacy;
    List<Medicine> medicines = [];
    try {
      //TODO: Change URL
      final res =
          await dio.get('$medicineURL/from_pharmacy', data: {'pharmacyId': pharmacyId});

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
        medicines.add(newMedicine);
        await database.medicineDao.insertMedicine(newMedicine);
      }
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
      final res = await dio.get('$medicineURL/with_ids', data: {'medicineIds': medicineIds});

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
}
