import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
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

  final _pharmacyService = PharmacyService();
  List<Pharmacy> _pharmacies = [];

  String mapTheme = '';
  LatLng? _currentPosition;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPosition().then((value) {
      setState(() {
        _currentPosition = value;
        _markers.add(
          Marker(
            markerId: const MarkerId('Your location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(120),
            position: _currentPosition!,
          ),
        );
      });
    });
    _pharmacyService.getPharmacies().then((pharmacies) {
      log('done!!');
      _pharmacies = pharmacies;
      _addPharmacyMarkers(pharmacies);
    });
    DefaultAssetBundle.of(context)
        .loadString('assets/map_themes/silver_map.json')
        .then((value) {
      mapTheme = value;
    });
    _fetchLocationUpdates().catchError((error) {
      log(error);
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _loadPosition().then((value) {
  //     setState(() {
  //       _currentPosition = value;
  //     });
  //   });
  //   _fetchLocationUpdates().catchError((error) {
  //     log(error);
  //   });
  // }

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
        //title: const Text('PharmacIST'),
        backgroundColor: Colors.transparent,
      ),
      body: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                style: mapTheme,
                zoomControlsEnabled: false,
                compassEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 17.0,
                ),
                markers: _markers,
              ),
              //const ScrollableWidget()
            ]),
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
      bottomNavigationBar: const BottomNavBar(),
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

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _savePosition(_currentPosition!);
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,
    );

    _statusListen = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
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
          _savePosition(_currentPosition!);
        });
      }
    });
  }

  void _addPharmacyMarkers(pharmacies) async {
    for (var pharmacy in pharmacies) {
      LatLng? coordinates;
      _getLatLngFromAddress(pharmacy.address).then((value) {
        coordinates = value;
        //log('Coordinates: $coordinates');
        final marker = Marker(
          markerId: MarkerId(pharmacy.id.toString()),
          position: coordinates!,
          infoWindow: InfoWindow(
            title: pharmacy.name,
            snippet: pharmacy.address,
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

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'School',
        ),
      ],
      //currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
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
