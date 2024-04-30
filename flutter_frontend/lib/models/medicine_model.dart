import 'dart:convert';

class Medicine {
  final int id;
  final String name;
  final String details;
  final List<int> picture;
  final int stock;
  final int pharmacyId;

  const Medicine({
    required this.id,
    required this.name,
    required this.details,
    required this.picture,
    required this.stock,
    required this.pharmacyId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'details': details,
      'picture': picture,
      'stock': stock,
      'pharmacyId': pharmacyId
    };
  }

  factory Medicine.fromJson(Map json) {
    return Medicine(
        id: json['id'],
        name: json['name'],
        details: json['details'],
        picture: base64Decode(json['picture']),
        stock: json['stock'],
        pharmacyId: json['pharmacyId']);
  }
}
