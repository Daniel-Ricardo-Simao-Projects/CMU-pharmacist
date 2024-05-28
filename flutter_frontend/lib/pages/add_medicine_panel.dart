import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class AddMedicinePanel extends StatefulWidget {
  final int pharmacyId;
  final Medicine medicine;

  const AddMedicinePanel(
      {super.key, required this.pharmacyId, required this.medicine});

  @override
  State<AddMedicinePanel> createState() => _AddMedicinePanelState();
}

class _AddMedicinePanelState extends State<AddMedicinePanel> {
  int _stock = 0;

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

  void _addMedicine() {
    Medicine newMedicine = Medicine(
      id: widget.medicine.id,
      name: widget.medicine.name,
      details: widget.medicine.details,
      picture: widget.medicine.picture,
      stock: _stock,
      pharmacyId: widget.pharmacyId,
      barcode: widget.medicine.barcode,
    );
    MedicineService().addMedicine(newMedicine);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.add_box,
                    color: Provider.of<ThemeProvider>(context)
                        .getTheme
                        .colorScheme
                        .secondary,
                    size: 30),
                const SizedBox(width: 10),
                const Text(
                  'Add ',
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 400)],
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    widget.medicine.name,
                    style: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: const [FontVariation('wght', 700)],
                      color: Provider.of<ThemeProvider>(context)
                          .getTheme
                          .colorScheme
                          .secondary,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Barcode',
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
                    widget.medicine.barcode,
                    style: const TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 400)],
                      fontSize: 18,
                    ),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      '$_stock',
                      style: const TextStyle(
                        fontFamily: 'JosefinSans',
                        fontVariations: [FontVariation('wght', 400)],
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
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
                    _addMedicine();
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
