import 'package:floor/floor.dart';
import 'package:flutter_frontend/models/medicine_model.dart';

@dao
abstract class MedicineDao {
  @Query('SELECT * FROM Medicine')
  Future<List<Medicine>> findAllMedicines();

  @Query('SELECT * FROM Medicine WHERE id = :id')
  Future<Medicine?> findMedicineById(int id);

  @insert
  Future<void> insertMedicine(Medicine medicine);

  @update
  Future<void> updateMedicine(Medicine medicine);

  @delete
  Future<void> deleteMedicine(Medicine medicine);
}
