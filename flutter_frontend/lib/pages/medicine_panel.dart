import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';

class MedicineInfoPage extends StatefulWidget {
  final Medicine medicine;
  const MedicineInfoPage({super.key, required this.medicine});

  @override
  State<MedicineInfoPage> createState() => _MedicineInfoPageState();
}

class _MedicineInfoPageState extends State<MedicineInfoPage> {
  Uint8List _decodeImage(List<int> imageBytes) {
    return Uint8List.fromList(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _medicineInfo(),
      ),
    );
  }

  ListView _medicineInfo() {
    return ListView(
      children: [
        _medicineImage(),
        const SizedBox(height: 20),
        _medicineDescription(widget.medicine),
        const SizedBox(height: 20),
        _pharmaciesAvailable(widget.medicine),
      ],
    );
  }

  Widget _pharmaciesAvailable(Medicine medicine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Pharmacies Available',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontVariations: [FontVariation('wght', 500)],
            color: accentColor, // TODO: Add new text colors (t1, t2)
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: primaryColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: PharmacyList(medicineId: medicine.id),
        ),
      ],
    );
  }

  Widget _medicineDescription(Medicine medicine) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: accentColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    medicine.name,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontVariations: [FontVariation('wght', 700)],
                      color: primaryColor,
                      fontSize: 17,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    medicine.details,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontVariations: [FontVariation('wght', 400)],
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: primaryColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.memory(
          _decodeImage(widget.medicine.picture),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: const Text(
        'Medicine Info',
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontVariations: [FontVariation('wght', 700)],
          color: textColor,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: accentColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          onPressed: () {}, // TODO: Implement notification logic
          icon: const Icon(Icons.notifications_outlined, color: accentColor),
        )
      ],
    );
  }
}

class PharmacyList extends StatefulWidget {
  final int medicineId;
  const PharmacyList({super.key, required this.medicineId});

  @override
  State<PharmacyList> createState() => _PharmacyListState();
}

class _PharmacyListState extends State<PharmacyList> {
  final medicineService = MedicineService();
  late Future<List<Pharmacy>> pharmacies;
  
  @override
  initState() {
    super.initState();
    pharmacies = medicineService.getPharmaciesWithMedicine(widget.medicineId);
  }

  Future<void> refreshPharmacies() async {
    setState(() {
      pharmacies = medicineService.getPharmaciesWithMedicine(widget.medicineId);
    });
  }

  Uint8List _decodeImage(List<int> imageBytes) {
    return Uint8List.fromList(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pharmacy>>(
      future: pharmacies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching pharmacies'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: MemoryImage(
                    _decodeImage(snapshot.data![index].picture),
                  ),
                ),
                title: Text(snapshot.data![index].name),
                subtitle: Text(snapshot.data![index].address),
              );
            },
          );
        }
      },
    );
  }
}
