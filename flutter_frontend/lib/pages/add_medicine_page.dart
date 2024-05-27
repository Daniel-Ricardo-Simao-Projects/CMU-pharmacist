import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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

    if (result == null) return;

    setState(() {
      _image = File(result.path);
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
      backgroundColor:
          Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
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
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .primary,
            borderRadius: BorderRadius.circular(15),
            border: Border(
                bottom: BorderSide(
                    color: Provider.of<ThemeProvider>(context)
                        .getTheme
                        .colorScheme
                        .outline,
                    width: 4)),
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
                if (_name.isEmpty ||
                    _image == null ||
                    _details.isEmpty ||
                    _stock == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please enter a name, image, valid details and a valid quantity.'),
                    ),
                  );
                } else {
                  _saveMedicine(_name, _stock, _details, _image!, pharmacyId);
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'JosefinSans',
                  fontVariations: [FontVariation('wght', 500)],
                  color: Colors.white,
                  fontSize: 16,
                ),
              )),
        ),
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .primary,
            borderRadius: BorderRadius.circular(15),
            border: Border(
                bottom: BorderSide(
                    color: Provider.of<ThemeProvider>(context)
                        .getTheme
                        .colorScheme
                        .outline,
                    width: 4)),
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
              color: Colors.white,
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
        Text(
          'Barcode:',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: const [FontVariation('wght', 700)],
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .secondary,
            fontSize: 18,
          ),
        ),
        Text(
          barcode,
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: const [FontVariation('wght', 400)],
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .secondary,
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
        Text(
          'Details',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: const [FontVariation('wght', 700)],
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .secondary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            contentPadding: const EdgeInsets.all(10),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(
                color: Provider.of<ThemeProvider>(context)
                    .getTheme
                    .colorScheme
                    .secondary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(
                  color: Provider.of<ThemeProvider>(context)
                      .getTheme
                      .colorScheme
                      .primary,
                  width: 2),
            ),
          ),
          cursorColor:
              Provider.of<ThemeProvider>(context).getTheme.colorScheme.primary,
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: const [FontVariation('wght', 400)],
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .secondary,
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
      Text(
        'Quantity',
        style: TextStyle(
          fontFamily: 'JosefinSans',
          fontVariations: const [FontVariation('wght', 700)],
          color: Provider.of<ThemeProvider>(context)
              .getTheme
              .colorScheme
              .secondary,
          fontSize: 18,
        ),
      ),
      Row(
        children: [
          IconButton(
            onPressed: () {
              _decrementStock();
            },
            icon: Icon(
              Icons.remove,
              color: Provider.of<ThemeProvider>(context)
                  .getTheme
                  .colorScheme
                  .secondary,
            ),
          ),
          Text(
            //TODO: Change this to input field
            '$_stock',
            style: TextStyle(
              fontFamily: 'JosefinSans',
              fontVariations: const [FontVariation('wght', 400)],
              color: Provider.of<ThemeProvider>(context)
                  .getTheme
                  .colorScheme
                  .secondary,
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: () {
              _incrementStock();
            },
            icon: Icon(
              Icons.add,
              color: Provider.of<ThemeProvider>(context)
                  .getTheme
                  .colorScheme
                  .secondary,
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
        Text(
          'Name',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: const [FontVariation('wght', 700)],
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .secondary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          style: const TextStyle(
            fontFamily: 'JosefinSans',
            fontVariations: [FontVariation('wght', 400)],
            fontSize: 15,
          ),
          cursorColor:
              Provider.of<ThemeProvider>(context).getTheme.colorScheme.primary,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: 10),
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Provider.of<ThemeProvider>(context)
                      .getTheme
                      .colorScheme
                      .primary,
                  width: 2),
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 35,
                    color: Provider.of<ThemeProvider>(context)
                        .getTheme
                        .colorScheme
                        .secondary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Click to add picture',
                    style: TextStyle(
                      color: Provider.of<ThemeProvider>(context)
                          .getTheme
                          .colorScheme
                          .secondary,
                      fontFamily: 'JosefinSans',
                      fontVariations: const [FontVariation('wght', 400)],
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
      backgroundColor:
          Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
      title: Text(
        'New Medicine',
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
      // By default the appBar adds a back button, but we can customize it
      leading: IconButton(
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
      ),
    );
  }
}
