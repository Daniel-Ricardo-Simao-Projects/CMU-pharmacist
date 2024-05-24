import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/pages/add_pharmacy_page.dart';
import 'package:flutter_frontend/pages/find_medicine_page.dart';
import 'package:flutter_frontend/pages/maps_page.dart';
import 'package:flutter_frontend/pages/pharmacy_page.dart';
import 'package:flutter_frontend/pages/user_login_page.dart';
import 'package:flutter_frontend/themes/colors.dart';

import 'models/pharmacy_model.dart';
import 'services/pharmacy_service.dart';
import 'database/app_database.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    systemNavigationBarColor: backgroundColor, // Transparent navigation bar
  ));
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  log(const String.fromEnvironment('URL'));

  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();

  final userDao = database.userDao;
  User? loggedInUser = await userDao.findLoggedInUser();

  runApp(MyApp(loggedInUser: loggedInUser));
}

class MyApp extends StatelessWidget {
  final User? loggedInUser;

  const MyApp({super.key, this.loggedInUser});

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
      home: loggedInUser == null ? const LoginPage() : const HomePage(),
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
        backgroundColor: backgroundColor,
        indicatorColor: primaryColor,
        selectedIndex: _currentPageIndex,
        height: 50,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.map_outlined, color: text2Color),
            icon: Icon(Icons.map_outlined, color: text1Color),
            label: 'Map',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle_outline, color: text2Color),
            icon: Icon(Icons.add_circle_outline, color: text1Color),
            label: 'Add Pharmacy',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search_outlined, color: text2Color),
            icon: Icon(Icons.search_outlined, color: text1Color),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon:
                Icon(Icons.account_circle_outlined, color: text2Color),
            icon: Icon(Icons.account_circle_outlined, color: text1Color),
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
