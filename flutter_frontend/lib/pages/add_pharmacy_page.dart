import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/constants.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/services/pharmacy_service.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:provider/provider.dart';

class AddPharmacyPage extends StatefulWidget {
  const AddPharmacyPage({super.key});

  @override
  State<AddPharmacyPage> createState() => _AddPharmacyPageState();
}

class _AddPharmacyPageState extends State<AddPharmacyPage> {
  String _name = '';
  File? _image;
  String _address = '';
  TextEditingController controller = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();

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
      resizeToAvoidBottomInset: false,
      backgroundColor:
          Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
      appBar: _appBar(context),
      body: Padding(
          padding:
              const EdgeInsets.only(left: 22, right: 22, top: 16, bottom: 20),
          child: _addPharmacyForm()),
    );
  }

  Widget _addPharmacyForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _imagePreview(),
          const SizedBox(height: 40),
          _nameField(),
          const SizedBox(height: 25),
          _addressField(),
          const SizedBox(height: 120),
          _bottomButtons(),
        ],
      ),
    );
  }

  Row _bottomButtons() {
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
              onPressed: submitNewPharmacy,
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

  void submitNewPharmacy() {
    if (_name.isEmpty || _image == null || _address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name, image, and a valid address.'),
          //backgroundColor: Colors.red,
        ),
      );
    } else {
      savePharmacy(_name, _address, _image!);
      // clear the fields
      _name = '';
      _image = null;
      _address = '';
      // Show a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Operation Successful'),
            content: const Text('The pharmacy has been created successfully.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Column _addressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .secondary,
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 18,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 260,
              child: GooglePlaceAutoCompleteTextField(
                textStyle: const TextStyle(
                  fontFamily: 'JosefinSans',
                  fontVariations: [FontVariation('wght', 400)],
                  fontSize: 15,
                ),
                focusNode: _addressFocusNode,
                textEditingController: controller,
                googleAPIKey: apiKey,
                inputDecoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 10),
                  border: const UnderlineInputBorder(),
                  isDense: true,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Provider.of<ThemeProvider>(context)
                            .getTheme
                            .colorScheme
                            .primary,
                        width: 2),
                  ),
                ),
                boxDecoration: const BoxDecoration(
                  border: null,
                ),
                containerVerticalPadding: 0,
                containerHorizontalPadding: 0,
                debounceTime: 400,
                countries: const ["pt"],
                // TODO: Review this comment
                //isLatLngRequired: true,
                // getPlaceDetailWithLatLng: (Prediction prediction) {
                //   log("placeDetails${prediction.lat}");
                // },
                itemClick: (Prediction prediction) {
                  controller.text = prediction.description ?? "";
                  controller.selection = TextSelection.fromPosition(
                      TextPosition(
                          offset: prediction.description?.length ?? 0));
                  setState(() {
                    _address = prediction.description ?? "";
                  });
                },
                seperatedBuilder: const Divider(),

                itemBuilder: (context, index, Prediction prediction) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(
                          width: 7,
                        ),
                        Expanded(child: Text(prediction.description ?? ""))
                      ],
                    ),
                  );
                },
                isCrossBtnShown: true,
              ),
            ),
            IconButton(
                onPressed: () {}, // TODO: Implement my current location button
                icon: Icon(Icons.my_location,
                    color: Provider.of<ThemeProvider>(context)
                        .getTheme
                        .colorScheme
                        .secondary,
                    size: 25)),
          ],
        ),
      ],
    );
  }

  Column _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name',
          style: TextStyle(
            fontFamily: 'JosefinSans',
            color: Provider.of<ThemeProvider>(context)
                .getTheme
                .colorScheme
                .secondary,
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 18,
          ),
        ),
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
              color: Provider.of<ThemeProvider>(context)
                  .getTheme
                  .colorScheme
                  .shadow,
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
                  const Text(
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

  void savePharmacy(String name, String address, File file) {
    String imageBytes = base64Encode(file.readAsBytesSync());
    Pharmacy pharmacy =
        Pharmacy(id: 0, name: name, address: address, picture: imageBytes);
    log('Pharmacy: $pharmacy.name, $pharmacy.address');
    PharmacyService().addPharmacy(pharmacy);

    //Navigator.pop(context);
  }
}

AppBar _appBar(BuildContext context) {
  return AppBar(
    backgroundColor:
        Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
    centerTitle: true,
    title: Text(
      'New Pharmacy',
      style: TextStyle(
        fontFamily: 'JosefinSans',
        fontVariations: const [FontVariation('wght', 700)],
        color:
            Provider.of<ThemeProvider>(context).getTheme.colorScheme.secondary,
        fontSize: 20,
      ),
    ),
  );
}
