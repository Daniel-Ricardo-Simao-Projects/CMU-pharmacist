class MedicineInPharmacy {
  final int medicineId;
  final int pharmacyId;
  final int stock;

  const MedicineInPharmacy({
    required this.medicineId,
    required this.pharmacyId,
    required this.stock,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'pharmacyId': pharmacyId,
      'stock': stock,
    };
  }

  factory MedicineInPharmacy.fromJson(Map json) {
    return MedicineInPharmacy(
        medicineId: json['medicineId'],
        pharmacyId: json['pharmacyId'],
        stock: json['stock']);
  }
}
