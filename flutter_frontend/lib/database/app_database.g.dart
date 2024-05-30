// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  MedicineDao? _medicineDaoInstance;

  PharmacyDao? _pharmacyDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `password` TEXT NOT NULL, `isLogged` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Medicine` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `details` TEXT NOT NULL, `picture` TEXT NOT NULL, `stock` INTEGER NOT NULL, `pharmacyId` INTEGER NOT NULL, `barcode` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Pharmacy` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `address` TEXT NOT NULL, `picture` TEXT NOT NULL, `latitude` REAL NOT NULL, `longitude` REAL NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  MedicineDao get medicineDao {
    return _medicineDaoInstance ??= _$MedicineDao(database, changeListener);
  }

  @override
  PharmacyDao get pharmacyDao {
    return _pharmacyDaoInstance ??= _$PharmacyDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'password': item.password,
                  'isLogged': item.isLogged ? 1 : 0
                }),
        _userUpdateAdapter = UpdateAdapter(
            database,
            'User',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'password': item.password,
                  'isLogged': item.isLogged ? 1 : 0
                }),
        _userDeletionAdapter = DeletionAdapter(
            database,
            'User',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'password': item.password,
                  'isLogged': item.isLogged ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final UpdateAdapter<User> _userUpdateAdapter;

  final DeletionAdapter<User> _userDeletionAdapter;

  @override
  Future<User?> findUserById(int id) async {
    return _queryAdapter.query('SELECT * FROM User WHERE id = ?1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            name: row['name'] as String,
            password: row['password'] as String,
            isLogged: (row['isLogged'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<User?> findLoggedInUser() async {
    return _queryAdapter.query('SELECT * FROM User WHERE isLogged = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            name: row['name'] as String,
            password: row['password'] as String,
            isLogged: (row['isLogged'] as int) != 0));
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userUpdateAdapter.update(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteUser(User user) async {
    await _userDeletionAdapter.delete(user);
  }
}

class _$MedicineDao extends MedicineDao {
  _$MedicineDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _medicineInsertionAdapter = InsertionAdapter(
            database,
            'Medicine',
            (Medicine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'details': item.details,
                  'picture': item.picture,
                  'stock': item.stock,
                  'pharmacyId': item.pharmacyId,
                  'barcode': item.barcode
                }),
        _medicineUpdateAdapter = UpdateAdapter(
            database,
            'Medicine',
            ['id'],
            (Medicine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'details': item.details,
                  'picture': item.picture,
                  'stock': item.stock,
                  'pharmacyId': item.pharmacyId,
                  'barcode': item.barcode
                }),
        _medicineDeletionAdapter = DeletionAdapter(
            database,
            'Medicine',
            ['id'],
            (Medicine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'details': item.details,
                  'picture': item.picture,
                  'stock': item.stock,
                  'pharmacyId': item.pharmacyId,
                  'barcode': item.barcode
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Medicine> _medicineInsertionAdapter;

  final UpdateAdapter<Medicine> _medicineUpdateAdapter;

  final DeletionAdapter<Medicine> _medicineDeletionAdapter;

  @override
  Future<List<Medicine>> findAllMedicines() async {
    return _queryAdapter.queryList('SELECT * FROM Medicine',
        mapper: (Map<String, Object?> row) => Medicine(
            id: row['id'] as int,
            name: row['name'] as String,
            details: row['details'] as String,
            picture: row['picture'] as String,
            stock: row['stock'] as int,
            pharmacyId: row['pharmacyId'] as int,
            barcode: row['barcode'] as String));
  }

  @override
  Future<Medicine?> findMedicineById(int id) async {
    return _queryAdapter.query('SELECT * FROM Medicine WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Medicine(
            id: row['id'] as int,
            name: row['name'] as String,
            details: row['details'] as String,
            picture: row['picture'] as String,
            stock: row['stock'] as int,
            pharmacyId: row['pharmacyId'] as int,
            barcode: row['barcode'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertMedicine(Medicine medicine) async {
    await _medicineInsertionAdapter.insert(medicine, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMedicine(Medicine medicine) async {
    await _medicineUpdateAdapter.update(medicine, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMedicine(Medicine medicine) async {
    await _medicineDeletionAdapter.delete(medicine);
  }
}

class _$PharmacyDao extends PharmacyDao {
  _$PharmacyDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _pharmacyInsertionAdapter = InsertionAdapter(
            database,
            'Pharmacy',
            (Pharmacy item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'address': item.address,
                  'picture': item.picture,
                  'latitude': item.latitude,
                  'longitude': item.longitude
                }),
        _pharmacyUpdateAdapter = UpdateAdapter(
            database,
            'Pharmacy',
            ['id'],
            (Pharmacy item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'address': item.address,
                  'picture': item.picture,
                  'latitude': item.latitude,
                  'longitude': item.longitude
                }),
        _pharmacyDeletionAdapter = DeletionAdapter(
            database,
            'Pharmacy',
            ['id'],
            (Pharmacy item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'address': item.address,
                  'picture': item.picture,
                  'latitude': item.latitude,
                  'longitude': item.longitude
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Pharmacy> _pharmacyInsertionAdapter;

  final UpdateAdapter<Pharmacy> _pharmacyUpdateAdapter;

  final DeletionAdapter<Pharmacy> _pharmacyDeletionAdapter;

  @override
  Future<List<Pharmacy>> findAllPharmacies() async {
    return _queryAdapter.queryList('SELECT * FROM Pharmacy',
        mapper: (Map<String, Object?> row) => Pharmacy(
            id: row['id'] as int,
            name: row['name'] as String,
            address: row['address'] as String,
            picture: row['picture'] as String,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double));
  }

  @override
  Future<Pharmacy?> findPharmacyById(int id) async {
    return _queryAdapter.query('SELECT * FROM Pharmacy WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Pharmacy(
            id: row['id'] as int,
            name: row['name'] as String,
            address: row['address'] as String,
            picture: row['picture'] as String,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double),
        arguments: [id]);
  }

  @override
  Future<void> insertPharmacy(Pharmacy pharmacy) async {
    await _pharmacyInsertionAdapter.insert(pharmacy, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePharmacy(Pharmacy pharmacy) async {
    await _pharmacyUpdateAdapter.update(pharmacy, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePharmacy(Pharmacy pharmacy) async {
    await _pharmacyDeletionAdapter.delete(pharmacy);
  }
}
