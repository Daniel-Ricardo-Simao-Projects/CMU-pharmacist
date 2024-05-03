import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/pharmacy_panel.dart';
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
        padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 13),
        child: _medicineInfo(),
      ),
    );
  }

  ListView _medicineInfo() {
    return ListView(
      children: [
        _medicineCard(widget.medicine),
        const SizedBox(height: 20),
        _pharmaciesAvailable(widget.medicine),
      ],
    );
  }

  Widget _medicineCard(Medicine medicine) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _medicineImage(),
              const SizedBox(height: 5),
              _medicineDescription(medicine),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pharmaciesAvailable(Medicine medicine) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pharmacies Available',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontVariations: [FontVariation('wght', 500)],
              color: accentColor, // TODO: Add new text colors (t1, t2)
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          PharmacyList(medicineId: medicine.id),
        ],
      ),
    );
  }

  Widget _medicineDescription(Medicine medicine) {
    return Container(
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontVariations: [FontVariation('wght', 700)],
                    color: Colors.black,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  medicine.details,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontVariations: [FontVariation('wght', 400)],
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: InkWell(
                  splashColor: Colors.blue,
                  highlightColor: Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PharmacyInfoPanel(pharmacy: snapshot.data![index]),
                    ),
                  );
                  },
                  child: Container(
                    height: 70,
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      height: 50,
                                      width: 50,
                                      _decodeImage(
                                          snapshot.data![index].picture),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 250,
                                    child: Text(
                                      snapshot.data![index].name,
                                      style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontVariations: [
                                          FontVariation('wght', 700)
                                        ],
                                        color: accentColor,
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                  Container(
                                    width: 250,
                                    child: Text(
                                      snapshot.data![index].address,
                                      style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontVariations: [
                                          FontVariation('wght', 400)
                                        ],
                                        color: Colors.black54,
                                        fontSize: 10,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
