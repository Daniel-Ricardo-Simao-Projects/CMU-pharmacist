import 'package:floor/floor.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';

@dao
abstract class PharmacyDao {
  @Query('SELECT * FROM Pharmacy')
  Future<List<Pharmacy>> findAllPharmacies();

  @Query('SELECT * FROM Pharmacy WHERE id = :id')
  Future<Pharmacy?> findPharmacyById(int id);

  @insert
  Future<void> insertPharmacy(Pharmacy pharmacy);

  @update
  Future<void> updatePharmacy(Pharmacy pharmacy);

  @delete
  Future<void> deletePharmacy(Pharmacy pharmacy); 
}
