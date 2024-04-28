class User {
  final int id;
  final String name;
  final String password;

  const User({
    required this.id,
    required this.name,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'password': password};
  }

  factory User.fromJson(Map json) {
    return User(
      id: json['id'],
      name: json['name'],
      password: json['address'],
    );
  }
}
