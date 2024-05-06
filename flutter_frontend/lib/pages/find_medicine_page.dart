import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/pharmacy_panel.dart';
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
      padding: const EdgeInsets.only(top: 5, right: 22, left: 22),
      child: TextField(
        decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            labelText: "Search for medicine"),
        onChanged: (value) {
          setState(() {
            _input = value;
          });
          fetchPharmacies(_input);
        },
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
                  title: Text(snapshot.data![index].name),
                  subtitle: Text(snapshot.data![index].address),
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
