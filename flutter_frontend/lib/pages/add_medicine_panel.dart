import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/medicine_model.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';

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
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
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
              children: [
                const Text(
                  'Add ',
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 400)],
                    color: subtext1Color,
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    widget.medicine.name,
                    style: const TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 700)],
                      color: accentColor,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Text(
                  ' to pharmacy',
                  style: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 400)],
                    color: subtext1Color,
                    fontSize: 15,
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
                  const Text(
                    'Barcode',
                    style: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 700)],
                      color: accentColor,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    widget.medicine.barcode,
                    style: const TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 400)],
                      color: subtext1Color,
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
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
                    _addMedicine();
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
