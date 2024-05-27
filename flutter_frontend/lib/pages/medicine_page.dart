import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/pharmacy_page.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MedicineInfoPage extends StatefulWidget {
  final Medicine medicine;
  const MedicineInfoPage({super.key, required this.medicine});

  @override
  State<MedicineInfoPage> createState() => _MedicineInfoPageState();
}

class _MedicineInfoPageState extends State<MedicineInfoPage> {
  bool isNotified = false;
  final medicineService = MedicineService();

  @override
  initState() {
    super.initState();
    checkIfNotified();
  }

  void checkIfNotified() async {
    bool notified = await medicineService.isNotified(widget.medicine.id);
    setState(() {
      isNotified = notified;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor:
              Provider.of<ThemeProvider>(context).getTheme.colorScheme.primary,
          floating: true,
          expandedHeight: 200,
          leading: backButton(context),
          actions: notifyButton,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Colors.white,
              child: Image.file(
                height: 50,
                width: 50,
                File(widget.medicine.picture),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          _medicineDescription(widget.medicine),
          const SizedBox(height: 20),
          _pharmaciesAvailable(widget.medicine),
        ])),
      ]),
    );
  }

  List<Widget> get notifyButton {
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
                toggleNotification();
              },
              icon: Icon(
                  isNotified
                      ? Icons.notifications
                      : Icons.notifications_outlined,
                  color: Provider.of<ThemeProvider>(context)
                      .getTheme
                      .colorScheme
                      .secondary),
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
            icon: Icon(
              Icons.arrow_back,
              color: Provider.of<ThemeProvider>(context)
                  .getTheme
                  .colorScheme
                  .secondary,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            padding: const EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  Widget _pharmaciesAvailable(Medicine medicine) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pharmacies Available',
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
          PharmacyList(medicineId: medicine.id),
        ],
      ),
    );
  }

  void toggleNotification() async {
    if (isNotified) {
      // Remove from favorites
      bool removed = await MedicineService()
          .removeMedicineFromNotifications(widget.medicine.id);
      if (removed) {
        setState(() {
          isNotified = false;
        });
      }
    } else {
      // Add to favorites
      bool added = await MedicineService()
          .addMedicineToNotifications(widget.medicine.id);
      if (added) {
        setState(() {
          isNotified = true;
        });
      }
    }
  }

  Widget _medicineDescription(Medicine medicine) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      medicine.name,
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
                      maxLines: 5,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      medicine.details,
                      style: const TextStyle(
                        fontFamily: 'JosefinSans',
                        fontVariations: [FontVariation('wght', 400)],
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                        builder: (context) =>
                            PharmacyInfoPanel(pharmacy: snapshot.data![index]),
                      ),
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
                                    width: 230,
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
                                    width: 230,
                                    child: Text(
                                      snapshot.data![index].address,
                                      style: const TextStyle(
                                        fontFamily: 'JosefinSans',
                                        fontVariations: [
                                          FontVariation('wght', 400)
                                        ],
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
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
