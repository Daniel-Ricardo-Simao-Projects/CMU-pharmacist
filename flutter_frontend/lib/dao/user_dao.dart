import 'package:floor/floor.dart';
import '../models/user_model.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM User WHERE id = :id')
  Future<User?> findUserById(int id);

  @Query('SELECT * FROM User WHERE isLogged = 1 LIMIT 1')
  Future<User?> findLoggedInUser();

  @insert
  Future<void> insertUser(User user);

  @update
  Future<void> updateUser(User user);

  @delete
  Future<void> deleteUser(User user);
}
