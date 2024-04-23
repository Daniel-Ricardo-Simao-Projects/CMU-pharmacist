import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/services/pharmacy_service.dart';
import 'package:image_picker/image_picker.dart';

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
      appBar: appbar(context),
      body:
          Padding(padding: const EdgeInsets.all(16), child: _addPharmacyForm()),
    );
  }

  Form _addPharmacyForm() {
    return Form(
      child: ListView(
        children: [
          const SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Address',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _address = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.green[200],
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ))
                : const Center(
                    child: Text(
                      'No image selected',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.green[100],
                ),
                child: IconButton(
                  onPressed: () {
                    _captureImage();
                  },
                  icon: const Icon(
                    Icons.photo_camera,
                    color: Colors.green,
                  ),
                  iconSize: 30,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.green[100],
                ),
                child: IconButton(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(
                    Icons.add_photo_alternate,
                    color: Colors.green,
                  ),
                  iconSize: 30,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              savePharmacy(_name, _address, _image!);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
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

AppBar appbar(BuildContext context) {
  return AppBar(
    title: const Text('New Pharmacy'),
    // By default the appBar adds a back button, but we can customize it
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.green),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  );
}
