import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState
    extends State<MapsPage> /*with AutomaticKeepAliveClientMixin*/ {
  late GoogleMapController mapController;
  StreamSubscription<Position>? _positionListen;

  String mapTheme = '';
  LatLng? _currentPosition;

  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPosition().then((value) {
      setState(() {
        _currentPosition = value;
      });
    });
    DefaultAssetBundle.of(context)
        .loadString('assets/map_themes/silver_map.json')
        .then((value) {
      mapTheme = value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPosition().then((value) {
      setState(() {
        _currentPosition = value;
      });
    });
    _fetchLocationUpdates().catchError((error) {
      print(error);
    });
  }

  @override
  void dispose() {
    _positionListen?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
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
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 17.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('Your location'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(120),
                    position: _currentPosition!,
                  ),
                },
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.2,
                maxChildSize: 0.8,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
              )
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
      _savePosition(_currentPosition!);
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      //distanceFilter: 5,
    );

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      print(status);
    });

    _positionListen =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      print(position == null
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
}
