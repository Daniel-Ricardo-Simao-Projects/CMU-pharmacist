import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/add_medicine_page.dart';
import 'package:flutter_frontend/pages/medicine_panel.dart';
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
          padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 13),
          child: _pharmacyInfo(widget.pharmacy),
        ));
  }

  Stack _pharmacyInfo(Pharmacy pharmacy) {
    return Stack(
      children: [
        ListView(
          children: [
            _pharmacyCard(pharmacy),
            const SizedBox(height: 20),
            _pharmacyMedicines(pharmacy),
          ],
        ),
        Positioned(
          bottom: 15,
          right: 5,
          child: _addMedicineButton(pharmacy.id),
        ),
      ],
    );
  }

  Widget _pharmacyCard(Pharmacy pharmacy) {
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
              _pharmacyImage(),
              const SizedBox(height: 5),
              _pharmacyDetails(pharmacy),
            ],
          ),
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medicines',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontVariations: [FontVariation('wght', 500)],
              color: accentColor, // TODO: Add new text colors (t1, t2)
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          MedicineList(pharmacyId: pharmacy.id),
        ],
      ),
    );
  }

  Widget _pharmacyDetails(Pharmacy pharmacy) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pharmacy.name,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontVariations: [FontVariation('wght', 700)],
                    color: Colors.black,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  pharmacy.address,
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
          const SizedBox(width: 5),
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.explore_outlined,
              color: Colors.black,
              size: 30,
            ),
          )
        ],
      ),
    );
  }

  Widget _pharmacyImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: primaryColor,
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
                        builder: (context) => MedicineInfoPage(
                          medicine: snapshot.data![index],
                        ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  SizedBox(
                                    width: 200,
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
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      snapshot.data![index].details,
                                      style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontVariations: [
                                          FontVariation('wght', 400)
                                        ],
                                        color: Colors.black87,
                                        fontSize: 10,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Stock: ${snapshot.data![index].stock}',
                                      style: const TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontVariations: [
                                          FontVariation('wght', 400)
                                        ],
                                        color: Colors.black87,
                                        fontSize: 10,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {},
                                child: const Icon(Icons.add,
                                    color: Colors.black,
                                    size: 25), // TODO: Implement add stock
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {},
                                child: const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.black,
                                    size: 25), // TODO: Implement reduce stock
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
