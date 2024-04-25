import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/pages/add_pharmacy_page.dart';
import 'package:flutter_frontend/pages/maps.dart';
import 'package:flutter_frontend/pages/pharmacy_panel.dart';
import 'package:flutter_frontend/product_service.dart';
import 'package:flutter_frontend/product_model.dart';
import 'package:flutter_frontend/themes/colors.dart';

import 'models/pharmacy_model.dart';
import 'services/pharmacy_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PharmacIST',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 73, 168, 112)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PharmacIST'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(title),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PharmacyList(),
                //child: ProductList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AddPharmacyButton(),
                  ShowMapButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddPharmacyButton extends StatelessWidget {
  const AddPharmacyButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text('Add Pharmacy'),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPharmacyPage()),
          );
        });
  }
}

class ShowMapButton extends StatelessWidget {
  const ShowMapButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map),
            SizedBox(width: 8),
            Text('Show Map'),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapsPage()),
          );
        });
  }
}

class PharmacyList extends StatefulWidget {
  const PharmacyList({super.key});

  @override
  State<PharmacyList> createState() => _PharmacyListState();
}

class _PharmacyListState extends State<PharmacyList> {
  final _pharmacyService = PharmacyService();
  late Future<List<Pharmacy>> _pharmacies;

  @override
  initState() {
    super.initState();
    _pharmacies = _pharmacyService.getPharmacies();
  }

  Future<void> _refreshPharmacies() async {
    setState(() {
      _pharmacies = _pharmacyService.getPharmacies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pharmacy>>(
      future: _pharmacies,
      builder: (context, snapshot) {
        var pharmacies = snapshot.data ?? [];

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _refreshPharmacies,
          child: ListView.builder(
            itemCount: pharmacies.length,
            itemBuilder: (context, index) {
              var pharmacy = pharmacies[index];
              return ListTile(
                title: Text(pharmacies[index].name),
                subtitle: Text(pharmacy.address),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PharmacyInfoPanel(pharmacy: pharmacy),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  final _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _productService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        var products = snapshot.data ?? [];

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _refreshProducts,
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              return ListTile(
                title: Text(products[index].name),
                subtitle: Text('#${product.id} ${product.description}'),
                trailing: Text('\$${product.price}'),
              );
            },
          ),
        );
      },
    );
  }
}
