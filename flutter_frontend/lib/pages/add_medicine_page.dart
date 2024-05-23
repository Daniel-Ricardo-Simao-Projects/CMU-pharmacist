import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:image_picker/image_picker.dart';

class AddMedicinePage extends StatefulWidget {
  final int PharmacyId;
  final String barcode;

  const AddMedicinePage({
    super.key,
    required this.PharmacyId,
    required this.barcode,
  });

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  String _name = '';
  int _stock = 0;
  String _details = '';
  File? _image;
  String barcode = '';

  @override
  void initState() {
    super.initState();
    barcode = widget.barcode;
  }

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
    String imageBytes = base64Encode(file.readAsBytesSync());
    Medicine newMedicine = Medicine(
      id: 0,
      name: name,
      stock: stock,
      details: details,
      picture: imageBytes,
      pharmacyId: pharmacyId,
      barcode: barcode,
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
        child: _addMedicineForm(),
      ),
    );
  }

  Widget _addMedicineForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TODO: Maybe wrap this as a Form with validation
          _imagePreview(),
          const SizedBox(height: 20),
          _nameField(),
          const SizedBox(height: 25),
          _barcodeField(widget.barcode),
          const SizedBox(height: 15),
          _quantityField(),
          const SizedBox(height: 20),
          _detailsField(),
          const SizedBox(height: 30),
          _bottomButtons(widget.PharmacyId),
        ],
      ),
    );
  }

  Widget _bottomButtons(int pharmacyId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          height: 55,
          width: 220,
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
          child: TextButton(
              onPressed: () {
                _saveMedicine(_name, _stock, _details, _image!, pharmacyId);
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'JosefinSans',
                  fontVariations: [FontVariation('wght', 500)],
                  color: text2Color,
                  fontSize: 16,
                ),
              )),
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
              color: text2Color,
            ),
            iconSize: 30,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _barcodeField(String barcode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Barcode:',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 700)],
            color: text1Color,
            fontSize: 18,
          ),
        ),
        Text(
          barcode,
          style: const TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 400)],
            color: text1Color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _detailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 700)],
            color: text1Color,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            contentPadding: const EdgeInsets.all(10),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: accentColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          cursorColor: primaryColor,
          style: const TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 400)],
            color: text1Color,
            fontSize: 14,
          ),
          maxLines: null,
          minLines: 4,
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

  Widget _quantityField() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text(
        'Quantity',
        style: TextStyle(
          fontFamily: 'JosefinSans',
          fontVariations: [FontVariation('wght', 700)],
          color: accentColor,
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
              fontFamily: 'JosefinSans',
              fontVariations: [FontVariation('wght', 400)],
              color: text1Color,
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

  Widget _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 700)],
            color: text1Color,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          style: const TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 400)],
            color: text1Color,
            fontSize: 15,
          ),
          cursorColor: primaryColor,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(bottom: 10),
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
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
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white.withOpacity(0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              blurStyle: BlurStyle.outer,
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
                      fontFamily: 'JosefinSans',
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
          fontFamily: 'JosefinSans',
          fontVariations: [FontVariation('wght', 700)],
          color: text1Color,
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
