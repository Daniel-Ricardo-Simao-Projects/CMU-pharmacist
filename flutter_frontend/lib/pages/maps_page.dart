import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/pharmacy_panel.dart';
import 'package:flutter_frontend/services/pharmacy_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with AutomaticKeepAliveClientMixin {
  late GoogleMapController mapController;
  StreamSubscription<Position>? _positionListen;
  StreamSubscription<ServiceStatus>? _statusListen;
  final Set<Marker> _markers = {};
  BitmapDescriptor _pharmacyIcon = BitmapDescriptor.defaultMarker;

  final _pharmacyService = PharmacyService();

  String mapTheme = '';
  LatLng? _currentPosition;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pharmacyService.getPharmacies().then((pharmacies) {
      _addPharmacyMarkers(pharmacies);
    });
    DefaultAssetBundle.of(context)
        .loadString('assets/map_themes/silver_map.json')
        .then((value) {
      mapTheme = value;
    });
    BitmapDescriptor.fromAssetImage(
      //const ImageConfiguration(devicePixelRatio: 0.01),
      ImageConfiguration.empty,
      'assets/icon/pharmacy_icon.png',
    ).then((icon) {
      _pharmacyIcon = icon;
    }).catchError((error) {
      log(error);
    });
    _fetchLocationUpdates().catchError((error) {
      log(error);
    });
  }

  @override
  void dispose() {
    _positionListen?.cancel();
    _statusListen?.cancel();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              onMapCreated: _onMapCreated,
              style: mapTheme,
              zoomControlsEnabled: false,
              compassEnabled: false,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 17.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('currentPosition'),
                  position: _currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                  infoWindow: const InfoWindow(
                    title: 'Current Position',
                    snippet: 'You are here',
                  ),
                ),
              }.union(_markers)
              //_markers,
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _currentPosition!,
                zoom: 17.0,
              ),
            ),
          );
        },
        child: const Icon(Icons.my_location),
      ),
      //bottomNavigationBar: const BottomNavBar(),
    );
  }

  Future<LatLng?> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getString('currentPosition');
    if (savedPosition != null) {
      final coordinates = savedPosition.split(',');
      return LatLng(
        double.parse(coordinates[0]),
        double.parse(coordinates[1]),
      );
    }
    return null;
  }

  Future<void> _savePosition(LatLng position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'currentPosition',
      '${position.latitude},${position.longitude}',
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _fetchLocationUpdates() async {
    //bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      //_savePosition(_currentPosition!);
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,
    );

    _statusListen =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      log(status.toString());
    });

    _positionListen =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      log(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          //_savePosition(_currentPosition!);
        });
      }
    });
  }

  void _addPharmacyMarkers(List<Pharmacy> pharmacies) async {
    for (Pharmacy p in pharmacies) {
      LatLng? coordinates;
      _getLatLngFromAddress(p.address).then((value) {
        coordinates = value;
        log("new marker: ${p.name} at $coordinates");
        final marker = Marker(
          markerId: MarkerId(p.id.toString()),
          position: coordinates!,
          icon: _pharmacyIcon,
          infoWindow: InfoWindow(
            title: p.name,
            snippet: p.address,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PharmacyInfoPanel(pharmacy: p)),
          ),
        );
        setState(() {
          _markers.add(marker);
        });
      });
    }
  }

  Future<LatLng> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      log('Error: ${e.toString()}');
    }
    return const LatLng(0, 0);
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      indicatorColor: const Color.fromARGB(127, 20, 219, 203),
      selectedIndex: _currentPageIndex,
      height: 60,
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
    );
  }
}

class ScrollableWidget extends StatelessWidget {
  const ScrollableWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.grey[300],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(5),
                    controller: scrollController,
                    itemCount: 20,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          title: Text('Item $index'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
