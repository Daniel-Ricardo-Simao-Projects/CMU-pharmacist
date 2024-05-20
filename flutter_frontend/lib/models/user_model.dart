import 'package:floor/floor.dart';

@Entity(tableName: 'User')
class User {
  @primaryKey
  final int id;
  final String name;
  final String password;
  bool isLogged = false;

  User({
    required this.id,
    required this.name,
    required this.password,
    required this.isLogged,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'password': password};
  }

  factory User.fromJson(Map json) {
    return User(
      id: json['data']['id'],
      name: json['data']['username'],
      password: json['data']['password'],
      isLogged: json['data']['isLogged'],
    );
  }

  factory User.fromJsonWithoutLastAttribute(Map json) {
    return User(
      id: json['data']['id'],
      name: json['data']['username'],
      password: json['data']['password'],
      isLogged: false,
    );
  }
}
