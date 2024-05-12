import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/add_medicine_page.dart';
import 'package:flutter_frontend/pages/medicine_panel.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:flutter_frontend/services/pharmacy_service.dart';

class PharmacyInfoPanel extends StatefulWidget {
  final Pharmacy pharmacy;

  const PharmacyInfoPanel({super.key, required this.pharmacy});

  @override
  _PharmacyInfoPanelState createState() => _PharmacyInfoPanelState();
}

class _PharmacyInfoPanelState extends State<PharmacyInfoPanel> {
  bool isFavorite = false; // Initially not a favorite

  @override
  void initState() {
    super.initState();
    // Check if the pharmacy is already in user's favorites when the widget is initialized
    checkFavoriteStatus();
  }

  void checkFavoriteStatus() async {
    // Fetch user's favorite pharmacies
    List<int> favoritePharmacyIds =
        await PharmacyService().getFavoritePharmaciesIds();
    // Check if the current pharmacy is in the list of favorites
    setState(() {
      isFavorite = favoritePharmacyIds.contains(widget.pharmacy.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: primaryColor,
          floating: true,
          expandedHeight: 200,
          leading: backButton(context),
          actions: favoritePharmacyButton,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.memory(
              _decodeImage(widget.pharmacy.picture),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          _pharmacyDetails(widget.pharmacy),
          const SizedBox(height: 20),
          _pharmacyMedicines(widget.pharmacy),
        ])),
      ]),
      floatingActionButton: _addMedicineButton(context),
    );
  }

  List<Widget> get favoritePharmacyButton {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 0,
                blurRadius: 5,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: IconButton(
              iconSize: 20,
              onPressed: () {
                toggleFavorite();
              },
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_outline,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Padding backButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Container(
        width: 35,
        height: 35,
        decoration: const BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: IconButton(
            iconSize: 20,
            icon: const Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () {
              Navigator.pop(context);
            },
            padding: const EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  FloatingActionButton _addMedicineButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AddMedicinePage(PharmacyId: widget.pharmacy.id)),
        );
      },
      backgroundColor: primaryColor,
      child: const Icon(
        Icons.add,
        color: text2Color,
      ),
    );
  }

  Widget _pharmacyMedicines(Pharmacy pharmacy) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medicines',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontVariations: [FontVariation('wght', 700)],
              color: accentColor,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          MedicineList(pharmacyId: pharmacy.id),
        ],
      ),
    );
  }

  Widget _pharmacyDetails(Pharmacy pharmacy) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 250,
                    child: Text(
                      pharmacy.name,
                      style: const TextStyle(
                        fontFamily: 'JosefinSans',
                        fontVariations: [FontVariation('wght', 700)],
                        color: accentColor,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: Text(
                      pharmacy.address,
                      style: const TextStyle(
                        fontFamily: 'JosefinSans',
                        fontVariations: [FontVariation('wght', 400)],
                        color: subtext1Color,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            InkWell(
              onTap: () {},
              child: const Icon(
                Icons.location_on,
                color: accentColor,
                size: 30,
              ),
            )
          ],
        ),
      ),
    );
  }

  void toggleFavorite() async {
    if (isFavorite) {
      // Remove from favorites
      bool removed =
          await PharmacyService().removeFavoritePharmacy(widget.pharmacy.id);
      if (removed) {
        setState(() {
          isFavorite = false;
        });
      }
    } else {
      // Add to favorites
      bool added =
          await PharmacyService().addFavoritePharmacy(widget.pharmacy.id);
      if (added) {
        setState(() {
          isFavorite = true;
        });
      }
    }
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
    // TODO: Implement refresh
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
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: glossyColor,
                      boxShadow:  [
                        BoxShadow(
                          color: shadow1Color,
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                          blurStyle: BlurStyle.outer,
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
                                    width: 160,
                                    child: Text(
                                      snapshot.data![index].name,
                                      style: const TextStyle(
                                        fontFamily: 'JosefinSans',
                                        fontVariations: [
                                          FontVariation('wght', 700)
                                        ],
                                        color: text1Color,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      snapshot.data![index].details,
                                      style: const TextStyle(
                                        fontFamily: 'JosefinSans',
                                        fontVariations: [
                                          FontVariation('wght', 400)
                                        ],
                                        color: text1Color,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      'Stock: ${snapshot.data![index].stock}',
                                      style: const TextStyle(
                                        fontFamily: 'JosefinSans',
                                        fontVariations: [
                                          FontVariation('wght', 400)
                                        ],
                                        color: text1Color,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                                    color: text1Color,
                                    size: 25), // TODO: Implement add stock
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {},
                                child: const Icon(Icons.shopping_bag_outlined,
                                    color: text1Color,
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
