import 'package:floor/floor.dart';

@entity
class Medicine {
  @primaryKey
  final int id;
  final String name;
  final String details;
  final String picture;
  int stock;
  int pharmacyId;
  final String barcode;

  Medicine({
    required this.id,
    required this.name,
    required this.details,
    required this.picture,
    required this.stock,
    required this.pharmacyId,
    required this.barcode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'details': details,
      'picture': picture,
      'stock': stock,
      'pharmacyId': pharmacyId,
      'barcode': barcode,
    };
  }

  factory Medicine.fromJson(Map json) {
    return Medicine(
        id: json['id'],
        name: json['name'],
        details: json['details'],
        picture: json['picture'],
        stock: json['stock'],
        pharmacyId: json['pharmacyId'],
        barcode: json['barcode']);
  }
}
