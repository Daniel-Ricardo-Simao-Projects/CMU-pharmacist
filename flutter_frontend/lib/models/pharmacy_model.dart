class Pharmacy {
  final int id;
  final String name;
  final String address;
  final String picture;

  const Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.picture,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'picture': picture
    };
  }

  factory Pharmacy.fromJson(Map json) {
    return Pharmacy(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      picture: json['picture']
    );
  }
}
