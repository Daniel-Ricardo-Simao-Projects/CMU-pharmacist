import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/pages/add_pharmacy_page.dart';
import 'package:flutter_frontend/pages/find_medicine_page.dart';
import 'package:flutter_frontend/pages/maps_page.dart';
import 'package:flutter_frontend/pages/pharmacy_panel.dart';
import 'package:flutter_frontend/pages/user_login_page.dart';
import 'package:flutter_frontend/product_service.dart';
import 'package:flutter_frontend/product_model.dart';
import 'package:flutter_frontend/themes/colors.dart';

import 'models/pharmacy_model.dart';
import 'services/pharmacy_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    //systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
  ));
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  final _pageOptions = <Widget>[
    const MapsPage(),
    const AddPharmacyPage(),
    const FindMedicinePage(),
    const Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPageIndex,
        children: _pageOptions,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        indicatorColor: const Color.fromARGB(127, 20, 219, 203),
        selectedIndex: _currentPageIndex,
        height: 50,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.map),
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle),
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Pharmacy',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
        //currentIndex: _selectedIndex,
        //onTap: _onItemTapped,
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
