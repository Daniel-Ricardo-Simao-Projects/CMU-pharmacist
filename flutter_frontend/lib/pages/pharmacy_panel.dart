import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/add_medicine_page.dart';
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

  Column _pharmacyInfo(Pharmacy pharmacy) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _pharmacyImage(),
        const SizedBox(height: 20),
        _pharmacyDetails(pharmacy),
        const SizedBox(height: 25),
        _pharmacyMedicines(pharmacy),
        const SizedBox(height: 25),
        _addMedicineButton(), // TODO: Maybe needs the pharmacy (?)
      ],
    );
  }

  Widget _addMedicineButton() {
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
                    builder: (context) => const AddMedicinePage()),
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
          // TODO: Change this do list view and add medicines containers
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
          Padding(
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
                ),
              ],
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
