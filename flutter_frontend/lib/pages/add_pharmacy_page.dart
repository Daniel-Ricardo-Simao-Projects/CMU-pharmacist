import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/services/pharmacy_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_frontend/themes/colors.dart';

class AddPharmacyPage extends StatefulWidget {
  const AddPharmacyPage({super.key});

  @override
  _AddPharmacyPageState createState() => _AddPharmacyPageState();
}

class _AddPharmacyPageState extends State<AddPharmacyPage> {
  String _name = '';
  File? _image;
  String _address = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _appBar(context),
      body: Padding(
          padding:
              const EdgeInsets.only(left: 22, right: 22, top: 16, bottom: 16),
          child: _addPharmacyForm()),
    );
  }

  Form _addPharmacyForm() {
    return Form(
      child: ListView(
        children: [
          const SizedBox(height: 10),
          _imagePreview(),
          const SizedBox(height: 60),
          _nameField(),
          const SizedBox(height: 25),
          _addressField(),
          const SizedBox(height: 150),
          bottomButtons(),
        ],
      ),
    );
  }

  Row bottomButtons() {
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
              savePharmacy(_name, _address, _image!);
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
        ),
      ],
    );
  }

  Column _addressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            color: textColor,
            fontVariations: [FontVariation('wght', 500)],
            fontSize: 16,
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            suffixIcon: Icon(
              Icons.add_location_alt_outlined,
              color: accentColor,
              size: 30,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _address = value;
            });
          },
        ),
      ],
    );
  }

  Column _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            color: textColor,
            fontVariations: [FontVariation('wght', 500)],
            fontSize: 16,
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
              //  labelText: 'Name',
              //  labelStyle: TextStyle(
              //    fontFamily: 'RobotoMono',
              //    color: textColor,
              //    fontVariations: [FontVariation('wght', 500)],
              //  ),
              border: UnderlineInputBorder()),
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

  void savePharmacy(String name, String address, File file) {
    List<int> imageBytes = file.readAsBytesSync();
    Pharmacy pharmacy =
        Pharmacy(id: 0, name: name, address: address, picture: imageBytes);
    PharmacyService().addPharmacy(pharmacy);

    Navigator.pop(context);
  }
}

AppBar _appBar(BuildContext context) {
  return AppBar(
    backgroundColor: backgroundColor,
    title: const Text(
      'New Pharmacy',
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
