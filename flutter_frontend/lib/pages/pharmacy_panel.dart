import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/add_medicine_page.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';

class PharmacyInfoPanel extends StatefulWidget {
  final Pharmacy pharmacy;

  const PharmacyInfoPanel({super.key, required this.pharmacy});

  @override
  _PharmacyInfoPanelState createState() => _PharmacyInfoPanelState();
}

class _PharmacyInfoPanelState extends State<PharmacyInfoPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _appBar(context),
        body: Padding(
          padding:
              const EdgeInsets.only(left: 22, right: 22, top: 10, bottom: 16),
          child: _pharmacyInfo(widget.pharmacy),
        ));
  }

  ListView _pharmacyInfo(Pharmacy pharmacy) {
    return ListView(
      children: [
        _pharmacyImage(),
        const SizedBox(height: 20),
        _pharmacyDetails(pharmacy),
        const SizedBox(height: 25),
        _pharmacyMedicines(pharmacy),
        const SizedBox(height: 25),
        _addMedicineButton(pharmacy.id),
      ],
    );
  }

  Widget _addMedicineButton(int pharmacyId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 60,
          width: 60,
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
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddMedicinePage(PharmacyId: pharmacyId)),
              );
            },
            icon: const Icon(Icons.add, color: backgroundColor, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _pharmacyMedicines(Pharmacy pharmacy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicines',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontVariations: [FontVariation('wght', 500)],
            color: accentColor, // TODO: Add new text colors (t1, t2)
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 220,
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
          child: MedicineList(pharmacyId: pharmacy.id),
        ),
      ],
    );
  }

  Widget _pharmacyDetails(Pharmacy pharmacy) {
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 8, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy.name,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontVariations: [FontVariation('wght', 700)],
                      color: primaryColor,
                      fontSize: 17,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    pharmacy.address,
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
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.pin_drop_outlined,
              color: backgroundColor,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pharmacyImage() {
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
          _decodeImage(widget.pharmacy.picture),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: const Text(
        'Pharmacy Info',
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
          onPressed: () {}, // TODO: Implement favorite logic
          icon: const Icon(Icons.star_outline, color: accentColor),
        )
      ],
    );
  }

  Uint8List _decodeImage(List<int> imageBytes) {
    return Uint8List.fromList(imageBytes);
  }
}

class MedicineList extends StatefulWidget {
  final int pharmacyId;
  const MedicineList({super.key, required this.pharmacyId});

  @override
  State<MedicineList> createState() => _MedicineListState();
}

class _MedicineListState extends State<MedicineList> {
  final medicineService = MedicineService();
  late Future<List<Medicine>> medicines;

  @override
  initState() {
    super.initState();
    medicines = medicineService.getMedicinesFromPharmacy(widget.pharmacyId);
  }

  Future<void> _refreshMedicines() async {
    setState(() {
      medicines = medicineService.getMedicinesFromPharmacy(widget.pharmacyId);
    });
  }

  Uint8List _decodeImage(List<int> imageBytes) {
    return Uint8List.fromList(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Medicine>>(
      future: medicines,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  snapshot.data![index].name,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontVariations: [FontVariation('wght', 700)],
                    color: accentColor,
                    fontSize: 17,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                subtitle: Text(
                  snapshot.data![index].details,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontVariations: [FontVariation('wght', 400)],
                    color: Colors.black87,
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: MemoryImage(
                    _decodeImage(snapshot.data![index].picture),
                  ),
                ),
                trailing: Text('Stock: ${snapshot.data![index].stock}'),
              );
            },
          );
        }
      },
    );
  }
}
