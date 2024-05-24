import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/pharmacy_page.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';

class FindMedicinePage extends StatefulWidget {
  const FindMedicinePage({super.key});

  @override
  State<FindMedicinePage> createState() => _FindMedicinePageState();
}

class _FindMedicinePageState extends State<FindMedicinePage> {
  String _input = '';
  late Future<List<Pharmacy>> _pharmacies = Future.value([]);

  @override
  void initState() {
    super.initState();
    _pharmacies = Future.value([]);
  }

  Future<void> fetchPharmacies(String medicine) async {
    if (medicine == '') {
      setState(() {
        _pharmacies = Future.value([]);
      });
      return;
    }
    MedicineService medicineService = MedicineService();
    List<Pharmacy> fetchedPharmacies =
        await medicineService.getPharmaciesFromSearch(medicine);
    setState(() {
      _pharmacies = Future.value(fetchedPharmacies);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          toolbarHeight: 10,
          backgroundColor: backgroundColor,
        ),
        body: Column(
          children: [
            _searchBox(),
            const SizedBox(height: 10),
            Expanded(
              child: PharmacyResultsList(pharmacies: _pharmacies),
            ),
          ],
        ));
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search_outlined, color: text2Color),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                style: const TextStyle(
                  fontFamily: 'JosefinSans',
                  fontVariations: [FontVariation('wght', 500)],
                  color: text2Color,
                  fontSize: 16,
                ),
                cursorColor: text2Color,
                decoration: const InputDecoration(
                  hintText: "Search for medicine",
                  hintStyle: TextStyle(
                    fontFamily: 'JosefinSans',
                    fontVariations: [FontVariation('wght', 500)],
                    color: text2Color,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _input = value;
                  });
                  fetchPharmacies(_input);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PharmacyResultsList extends StatefulWidget {
  final Future<List<Pharmacy>> pharmacies;
  const PharmacyResultsList({super.key, required this.pharmacies});

  @override
  State<PharmacyResultsList> createState() => PharmacyResultsListState();
}

class PharmacyResultsListState extends State<PharmacyResultsList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pharmacy>>(
        future: widget.pharmacies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching pharmacies'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.local_pharmacy, color: accentColor),
                  title: Text(
                    snapshot.data![index].name,
                    style: const TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 500)],
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    snapshot.data![index].address,
                    style: const TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 400)],
                      color: subtext1Color,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PharmacyInfoPanel(pharmacy: snapshot.data![index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        });
  }
}
