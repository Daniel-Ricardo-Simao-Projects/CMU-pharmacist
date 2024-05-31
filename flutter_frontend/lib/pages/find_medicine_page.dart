import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/pharmacy_page.dart';
import 'package:flutter_frontend/services/medicine_service.dart';
import 'package:flutter_frontend/themes/colors.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

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
    List<Pharmacy> fetchedPharmacies = [];
    Position? position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      String location = '${position.latitude}|${position.longitude}';
      fetchedPharmacies =
          await medicineService.getPharmaciesFromSearch(medicine, location);
    }
    setState(() {
      _pharmacies = Future.value(fetchedPharmacies);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
        appBar: AppBar(
          toolbarHeight: 10,
          backgroundColor:
              Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
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
            Expanded(
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
          } else if (snapshot.data!.isEmpty) {
            return Center(
                child: Text(
              'Search for pharmacies\nwith a medicine',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JosefinSans',
                fontVariations: const [FontVariation('wght', 500)],
                color: Provider.of<ThemeProvider>(context).getTheme.colorScheme.secondary,
                fontSize: 16,
              ),
            ));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.local_pharmacy,
                      color: Provider.of<ThemeProvider>(context)
                          .getTheme
                          .colorScheme
                          .secondary),
                  title: Text(
                    snapshot.data![index].name,
                    style: TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: const [FontVariation('wght', 500)],
                      color: Provider.of<ThemeProvider>(context)
                          .getTheme
                          .colorScheme
                          .primary,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    snapshot.data![index].address,
                    style: const TextStyle(
                      fontFamily: 'JosefinSans',
                      fontVariations: [FontVariation('wght', 400)],
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    print("Tapped on pharmacy with id: ${snapshot.data![index].id}");
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
