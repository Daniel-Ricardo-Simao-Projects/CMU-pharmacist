import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter_frontend/dao/medicine_dao.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../models/user_model.dart';
import '../dao/user_dao.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [User, Medicine])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
  MedicineDao get medicineDao;
}
