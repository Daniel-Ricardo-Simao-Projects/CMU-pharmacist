import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:image_picker/image_picker.dart';

class AddMedicinePage extends StatefulWidget {
  final int PharmacyId;

  const AddMedicinePage({super.key, required this.PharmacyId});

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  String _name = '';
  int _stock = 0;
  String _details = '';
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: source);

    setState(() {
      _image = File(result!.path);
    });
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(result!.path);
    });
  }

  void _incrementStock() {
    setState(() {
      _stock++;
    });
  }

  void _decrementStock() {
    setState(() {
      if (_stock > 0) {
        _stock--;
      }
    });
  }

  void _saveMedicine(
      String name, int stock, String details, File file, int pharmacyId) {
    List<int> imageBytes = file.readAsBytesSync();
    Medicine newMedicine = Medicine(
      id: 0,
      name: name,
      stock: stock,
      details: details,
      picture: imageBytes,
      pharmacyId: pharmacyId,
    );
    MedicineService().addMedicine(newMedicine);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _appBar(context),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 22, right: 22, top: 16, bottom: 16),
        child: ListView(
          children: [
            // TODO: Maybe wrap this as a Form
            // TODO: Add validation to the fields
            _imagePreview(),
            const SizedBox(height: 20),
            _addNameField(),
            const SizedBox(height: 20),
            _addQuantityField(),
            const SizedBox(height: 20),
            _addDetailsField(),
            const SizedBox(height: 30),
            _bottomButtons(widget.PharmacyId),
          ],
        ),
      ),
    );
  }

  Widget _bottomButtons(int pharmacyId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 250,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: const Border(
                bottom: BorderSide(color: primaryBorderColor, width: 4)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            onPressed: () {
              _saveMedicine(_name, _stock, _details, _image!, pharmacyId);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 15,
                fontVariations: [FontVariation('wght', 500)],
                color: textColor,
              ),
            ),
          ),
        ),
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(15),
            border: const Border(
                bottom: BorderSide(color: primaryBorderColor, width: 4)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              _captureImage();
            },
            icon: const Icon(
              Icons.photo_camera_outlined,
            ),
            iconSize: 30,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        )
      ],
    );
  }

  Widget _addDetailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontVariations: [FontVariation('wght', 500)],
            color: textColor,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          decoration: const InputDecoration(
            filled: true,
            fillColor: primaryColor,
            contentPadding: EdgeInsets.all(5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: accentColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: accentColor),
            ),
          ),
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontVariations: [FontVariation('wght', 400)],
            color: textColor,
            fontSize: 14,
          ),
          maxLines: null,
          minLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some details about the medicine.';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _details = value;
            });
          },
        ),
      ],
    );
  }

  Widget _addQuantityField() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text(
        'Quantity',
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontVariations: [FontVariation('wght', 500)],
          color: textColor,
          fontSize: 18,
        ),
      ),
      Row(
        children: [
          IconButton(
            onPressed: () {
              _decrementStock();
            },
            icon: const Icon(
              Icons.remove,
              color: accentColor,
            ),
          ),
          Text(
            //TODO: Change this to input field
            '$_stock',
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontVariations: [FontVariation('wght', 400)],
              color: textColor,
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: () {
              _incrementStock();
            },
            icon: const Icon(
              Icons.add,
              color: accentColor,
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _addNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontVariations: [FontVariation('wght', 500)],
            color: textColor,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontVariations: [FontVariation('wght', 400)],
            color: textColor,
            fontSize: 16,
          ),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: accentColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: accentColor),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
      ],
    );
  }

  InkWell _imagePreview() {
    return InkWell(
      onTap: () {
        _pickImage(ImageSource.gallery);
      },
      child: Container(
        width: double.infinity,
        height: 200,
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
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                ))
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 35,
                    color: accentColor,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Click to add picture',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontVariations: [FontVariation('wght', 400)],
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: const Text(
        'New Medicine',
        style: TextStyle(
          fontFamily: 'RobotoMono',
          fontVariations: [FontVariation('wght', 700)],
          color: textColor,
          fontSize: 20,
        ),
      ),
      // By default the appBar adds a back button, but we can customize it
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: accentColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
