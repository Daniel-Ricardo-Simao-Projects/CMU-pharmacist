import 'package:floor/floor.dart';

@entity
class Pharmacy {
  @primaryKey
  final int id;
  final String name;
  final String address;
  String picture;
  final double latitude;
  final double longitude;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.picture,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address, 'picture': picture, 'latitude': latitude, 'longitude': longitude};
  }

  factory Pharmacy.fromJson(Map json) {
    return Pharmacy(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        picture: json['picture'],
        latitude: json['latitude'],
        longitude: json['longitude']);
  }
}
