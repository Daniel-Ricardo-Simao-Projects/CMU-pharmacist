import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/add_medicine_page.dart';
import 'package:flutter_frontend/pages/add_medicine_panel.dart';
import 'package:flutter_frontend/pages/medicine_page.dart';
import 'package:flutter_frontend/pages/purchase_medicine_panel.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:flutter_frontend/services/pharmacy_service.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class PharmacyInfoPanel extends StatefulWidget {
  final Pharmacy pharmacy;

  const PharmacyInfoPanel({super.key, required this.pharmacy});

  @override
  State<PharmacyInfoPanel> createState() => _PharmacyInfoPanelState();
}

class _PharmacyInfoPanelState extends State<PharmacyInfoPanel> {
  bool isFavorite = false; // Initially not a favorite
  final medicineService = MedicineService();
  late Future<List<Medicine>> medicines;

  @override
  void initState() {
    super.initState();
    // Check if the pharmacy is already in user's favorites when the widget is initialized
    checkFavoriteStatus();
    medicines = medicineService.getMedicinesFromPharmacy(widget.pharmacy.id);
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

  Future<void> _refreshMedicines() async {
    setState(() {
      medicines = medicineService.getMedicinesFromPharmacy(widget.pharmacy.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
      body: RefreshIndicator(
        onRefresh: _refreshMedicines,
        child: CustomScrollView(slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .primary,
            floating: true,
            expandedHeight: 200,
            leading: backButton(context),
            actions: favoritePharmacyButton,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(
                height: 50,
                width: 50,
                File(widget.pharmacy.picture),
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
      ),
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
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .background,
            shape: BoxShape.circle,
            boxShadow: const [
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
                color: Provider.of<ThemeProvider>(context)
                    .getTheme
                    .colorScheme
                    .secondary,
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
        decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context)
              .getTheme
              .colorScheme
              .background,
          shape: BoxShape.circle,
          boxShadow: const [
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
            icon: Icon(Icons.arrow_back,
                color: Provider.of<ThemeProvider>(context)
                    .getTheme
                    .colorScheme
                    .secondary),
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
      onPressed: () async {
        var res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SimpleBarcodeScannerPage(),
            ));
        if (res != null) {
          var medicine =
              await MedicineService().getMedicineFromBarcode(res.toString());
          if (medicine.id != 0) {
            showModalBottomSheet(
                context: context, // TODO: make this better
                builder: (BuildContext context) {
                  return AddMedicinePanel(
                    pharmacyId: widget.pharmacy.id,
                    medicine: medicine,
                  );
                });
          } else {
            Navigator.push(
              context, // TODO: make this better
              MaterialPageRoute(
                builder: (context) => AddMedicinePage(
                  pharmacyId: widget.pharmacy.id,
                  barcode: res.toString(),
                ),
              ),
            );
          }
        } else {
          // If the barcode is not found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barcode not found'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      backgroundColor:
          Provider.of<ThemeProvider>(context).getTheme.colorScheme.primary,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  Widget _pharmacyMedicines(Pharmacy pharmacy) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medicines',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontVariations: const [FontVariation('wght', 700)],
              color: Provider.of<ThemeProvider>(context)
                  .getTheme
                  .colorScheme
                  .secondary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          _medicines(context, medicines),
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
                      style: TextStyle(
                        fontFamily: 'JosefinSans',
                        fontVariations: const [FontVariation('wght', 700)],
                        color: Provider.of<ThemeProvider>(context)
                            .getTheme
                            .colorScheme
                            .secondary,
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
              child: Icon(
                Icons.location_on,
                color: Provider.of<ThemeProvider>(context)
                    .getTheme
                    .colorScheme
                    .secondary,
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

  Widget _medicines(BuildContext context, Future<List<Medicine>> medicines) {
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
                  splashColor: Provider.of<ThemeProvider>(context)
                      .getTheme
                      .colorScheme
                      .primary,
                  highlightColor: Provider.of<ThemeProvider>(context)
                      .getTheme
                      .colorScheme
                      .primary,
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
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return AddMedicinePanel(
                          pharmacyId: widget.pharmacy.id,
                          medicine: snapshot.data![index],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: glossyColor,
                      boxShadow: [
                        BoxShadow(
                          color: Provider.of<ThemeProvider>(context)
                              .getTheme
                              .colorScheme
                              .shadow,
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
                                    child: Image.file(
                                      height: 50,
                                      width: 50,
                                      File(snapshot.data![index].picture),
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
                                      style: TextStyle(
                                        fontFamily: 'JosefinSans',
                                        fontVariations: const [
                                          FontVariation('wght', 700)
                                        ],
                                        color:
                                            Provider.of<ThemeProvider>(context)
                                                .getTheme
                                                .colorScheme
                                                .secondary,
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
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return PurchaseMedicinePanel(
                                    pharmacyId: widget.pharmacy.id,
                                    medicine: snapshot.data![index],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.shopping_bag_outlined,
                                color: Provider.of<ThemeProvider>(context)
                                    .getTheme
                                    .colorScheme
                                    .secondary,
                                size: 28),
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
