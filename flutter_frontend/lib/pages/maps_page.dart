import 'dart:async';
import 'dart:convert';
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

class _MapsPageState extends State<MapsPage>
    with AutomaticKeepAliveClientMixin {
  late GoogleMapController mapController;
  StreamSubscription<Position>? _positionListen;
  StreamSubscription<ServiceStatus>? _statusListen;
  BitmapDescriptor _pharmacyIcon = BitmapDescriptor.defaultMarker;

  final _pharmacyService = PharmacyService();

  final Set<Marker> _markers = {};
  final Map<String, dynamic> _savedMarkers = {};
  String _mapTheme = '';
  LatLng? _currentPosition;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _loadPosition().catchError((error) {
      log(error);
    });
    _loadMarkers().catchError((error) {
      log(error);
    });

    _pharmacyService.getPharmacies().then((pharmacies) {
      _addPharmacyMarkers(pharmacies);
    });

    DefaultAssetBundle.of(context)
        .loadString('assets/map_themes/silver_map.json')
        .then((value) {
      _mapTheme = value;
    });

    BitmapDescriptor.fromAssetImage(
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
          : Stack(children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                style: _mapTheme,
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
                }.union(_markers),
                //_markers,
              ),
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
      //bottomNavigationBar: const BottomNavBar(),
    );
  }

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getString('currentPosition');
    if (savedPosition != null) {
      log('Loading position...');
      final coordinates = savedPosition.split(',');
      setState(() => _currentPosition = LatLng(
            double.parse(coordinates[0]),
            double.parse(coordinates[1]),
          ));
    }
  }

  Future<void> _loadMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final markersString = prefs.getStringList('markers');
    if (markersString != null) {
      log('Loading markers...');
      for (var marker in markersString) {
        final json = jsonDecode(marker);
        _savedMarkers.addAll(json);
      }
      log('Loaded markers: $_savedMarkers');
    }
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'currentPosition',
      '${_currentPosition!.latitude},${_currentPosition!.longitude}',
    );
  }

  Future<void> _saveMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> markers = [];
    for (Marker marker in _markers) {
      final pharmacyid = marker.markerId.value;
      final position =
          '${marker.position.latitude},${marker.position.longitude}';
      markers.add(jsonEncode({pharmacyid: position}));
    }
    await prefs.setStringList('markers', markers);
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
      _savePosition();
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
        final pos = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = pos;
          _savePosition().catchError((error) {
            log(error);
          });
        });
      }
    });
  }

  void _addPharmacyMarkers(List<Pharmacy> pharmacies) async {
    for (Pharmacy p in pharmacies) {
      LatLng? coordinates;
      if (_savedMarkers.containsKey(p.id.toString())) {
        log("marker already saved");
        final positionStr =
            _savedMarkers[p.id.toString()].toString().split(',');
        coordinates = LatLng(
          double.parse(positionStr[0]),
          double.parse(positionStr[1]),
        );
      } else {
        await _getLatLngFromAddress(p.address).then((value) {
          coordinates = value;
        });
      }
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
      _markers.add(marker);
    }
    log("saving markers....");
    setState(() {});
    _saveMarkers().catchError((error) {
      log(error);
    });
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
