import 'dart:convert';

class Pharmacy {
  final int id;
  final String name;
  final String address;
  final List<int> picture;

  const Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.picture,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address, 'picture': picture};
  }

  factory Pharmacy.fromJson(Map json) {
    return Pharmacy(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        // Convert base64 string to List<int>
        picture: base64Decode(json['picture']));
  }
}
