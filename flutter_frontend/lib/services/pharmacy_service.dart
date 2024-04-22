import 'package:dio/dio.dart';
import '../models/pharmacy_model.dart';

class PharmacyService {
  final String pharmaciesURL = 'http://localhost:5000/pharmacies';
  final Dio dio = Dio();

  PharmacyService();

  Future<void> addPharmacy(Pharmacy pharmacy) async {
    try {
      await dio.post(pharmaciesURL, data: pharmacy.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Pharmacy>> getPharmacies() async {
    late List<Pharmacy> pharmacies;
    try {
      final res = await dio.get(pharmaciesURL);

      print("GETTING PHARMACIES");
      pharmacies = res.data['pharmacies']
          .map<Pharmacy>(
            (item) => Pharmacy.fromJson(item),
          )
          .toList();
      for (var pharmacy in pharmacies) {
        print(pharmacy.name);
        print(pharmacy.address);
        print(pharmacy.picture);
      }
    } catch (e) {
      pharmacies = [];
    }
    return pharmacies;
  }
}
