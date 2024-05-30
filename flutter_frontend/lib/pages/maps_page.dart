import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/database/app_database.dart';
import 'package:flutter_frontend/models/pharmacy_model.dart';
import 'package:flutter_frontend/pages/add_pharmacy_page.dart';
import 'package:flutter_frontend/pages/error_scaffold.dart';
import 'package:flutter_frontend/pages/pharmacy_page.dart';
import 'package:flutter_frontend/services/pharmacy_service.dart';
import 'package:flutter_frontend/themes/theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

Future<LatLng> getLatLngFromAddress(String address) async {
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

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  StreamSubscription<Position>? _positionListen;
  StreamSubscription<ServiceStatus>? _statusListen;

  BitmapDescriptor _pharmacyIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _favoritePharmacyIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _addLocationIcon = BitmapDescriptor.defaultMarker;

  final _pharmacyService = PharmacyService();

  final Set<Marker> _markers = {};
  final Map<String, dynamic> _savedMarkers = {};
  final String _mapTheme = '';
  LatLng? _currentPosition;
  List<Pharmacy> _pharmacies = [];
  List<Pharmacy> _searchResults = [];
  final _searchBarController = FloatingSearchBarController();

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    _initializeState().catchError((error) {
      log(error.toString());
    });

    _initializeIcons();

    _fetchLocationUpdates().catchError((error) {
      log(error);
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    _positionListen?.cancel();
    _statusListen?.cancel();
    _searchBarController.dispose();
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(fit: StackFit.expand, children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                style: _mapTheme,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 17.0,
                ),
                markers: _markers,
                onTap: (coordinates) {
                  addPharmacyOnLocation(coordinates, context);
                }, //_markers,
              ),
              buildFloatingSearchBar(),
              Positioned(
                bottom: 60,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'myLocation',
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
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 120,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'refresh',
                  onPressed: _isRefreshing
                      ? null
                      : () {
                          refreshButtonFunction();
                        },
                  child: _isRefreshing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.replay, color: Colors.white),
                ),
              ),
            ]),
    );
  }

  void refreshButtonFunction() {
    setState(() {
      _isRefreshing = true;
    });
    _pharmacyService.getPharmacies().then((pharmacies) async {
      _pharmacies.clear();
      _pharmacies.addAll(pharmacies);
      _addPharmacyMarkers(pharmacies);
      await _savePharmacies().catchError((error) {
        log(error);
      });
      setState(() {
        _isRefreshing = false;
      });
    }).catchError((error) {
      showErrorSnackBar(context, "failed to fetch pharmacies");
      setState(() {
        _isRefreshing = false;
      });
    });
  }

  void _initializeIcons() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/icon/pharmacy_icon.png',
    ).then((icon) {
      _pharmacyIcon = icon;
    }).catchError((error) {
      log(error);
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/icon/favorite.png',
    ).then((icon) {
      _favoritePharmacyIcon = icon;
    }).catchError((error) {
      log(error);
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/icon/add-location.png',
    ).then((icon) {
      _addLocationIcon = icon;
    }).catchError((error) {
      log(error);
    });
  }

  void addPharmacyOnLocation(LatLng coordinates, BuildContext context) {
    var markerId = const MarkerId('newMarker');
    var marker = Marker(
        markerId: markerId,
        position: coordinates,
        icon: _addLocationIcon,
        infoWindow: const InfoWindow(
          title: 'Add a new pharmacy',
        ),
        onTap: () async {
          List<Placemark> placemarks =
              await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
          Placemark place = placemarks[0];
          String address = "${place.street}, ${place.locality}, ${place.country}";
          log("address: $address");

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPharmacyPage(
                  address: address,
                ),
              ),
            );
          }
        });

    // Find the old marker with the same markerId
    Marker? oldMarker = _markers.firstWhere((m) => m.markerId == markerId,
        orElse: () => const Marker(markerId: MarkerId("null")));

    setState(() {
      if (oldMarker.markerId != const MarkerId("null")) {
        _markers.remove(oldMarker);
      }
      _markers.add(marker);
    });
  }

  Future<void> _initializeState() async {
    try {
      await _loadPosition();
      await _loadMarkers();
      var pharmacies = await _loadPharmacies();
      if (pharmacies.isEmpty) {
        pharmacies = await _pharmacyService.getPharmacies();
      }
      _pharmacies.addAll(pharmacies);
      await _savePharmacies();
      _addPharmacyMarkers(pharmacies);
    } catch (error) {
      showErrorSnackBar(context, error.toString());
    }
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

  Future<List<Pharmacy>> _loadPharmacies() async {
    log('Loading pharmacies...');
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final pharmacies = await database.pharmacyDao.findAllPharmacies();
    database.close();
    if (pharmacies.isEmpty) {
      log('No pharmacies found in database');
      return [];
    }
    return pharmacies;
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
      final position = '${marker.position.latitude},${marker.position.longitude}';
      markers.add(jsonEncode({pharmacyid: position}));
    }
    await prefs.setStringList('markers', markers);
  }

  Future<void> _savePharmacies() async {
    log("saving pharmacies....");
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    for (Pharmacy p in _pharmacies) {
      final pharmacy = await database.pharmacyDao.findPharmacyById(p.id);
      if (pharmacy != null) {
        continue;
      }
      log("saving pharmacy: ${p.name}");
      await database.pharmacyDao.insertPharmacy(p);
    }
    database.close();
    log("saved pharmacies");
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

    Position position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _savePosition();
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _statusListen = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      log("status:$status.toString()");
    });

    _positionListen = Geolocator.getPositionStream(locationSettings: locationSettings)
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
    if (pharmacies.isEmpty) {
      return;
    }
    // get favorite pharmacies ids if any
    List<int> favoritePharmacies = await _pharmacyService.getFavoritePharmaciesIds();

    for (Pharmacy p in pharmacies) {
      //log("adding marker for ${p.name}");
      LatLng? coordinates;
      if (_savedMarkers.containsKey(p.id.toString())) {
        //log("marker ${p.name} already saved");
        final positionStr = _savedMarkers[p.id.toString()].toString().split(',');
        coordinates = LatLng(
          double.parse(positionStr[0]),
          double.parse(positionStr[1]),
        );
      } else {
        log("getting coordinates for ${p.name} at ${p.address}");
        // await getLatLngFromAddress(p.address).then((value) {
        //   coordinates = value;
        // });
        coordinates = LatLng(p.latitude, p.longitude);
        log("coordinates: $coordinates");
      }

      //log("new marker: ${p.name} at $coordinates");
      final marker = Marker(
        markerId: MarkerId(p.id.toString()),
        position: coordinates,
        icon: favoritePharmacies.contains(p.id) ? _favoritePharmacyIcon : _pharmacyIcon,
        infoWindow: InfoWindow(
          title: p.name,
          snippet: p.address,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PharmacyInfoPanel(pharmacy: p)),
        ),
      );
      if (!_markers.contains(marker)) {
        setState(() {
          _markers.add(marker);
        });
      }
    }
    log("saving markers....");
    _saveMarkers().catchError((error) {
      log(error);
    });
  }

  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      backgroundColor:
          Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
      controller: _searchBarController,
      hint: 'Search Pharmacies...',
      hintStyle: TextStyle(
        color: Provider.of<ThemeProvider>(context).getTheme.colorScheme.secondary,
        fontFamily: 'JosefinSans',
        fontVariations: const [FontVariation('wght', 500)],
        fontSize: 15,
      ),
      borderRadius: BorderRadius.circular(50),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56, left: 10, right: 10),
      transitionDuration: const Duration(milliseconds: 5),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 1000),
      onQueryChanged: (query) {
        setState(() {
          _searchResults = searchResults(query);
        });
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: Icon(Icons.place,
                color: Provider.of<ThemeProvider>(
                  context,
                ).getTheme.colorScheme.secondary),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Provider.of<ThemeProvider>(context).getTheme.colorScheme.background,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _searchResults.map((pharmacy) {
                return ListTile(
                  title: Text(pharmacy.name),
                  subtitle: Text(pharmacy.address),
                  onTap: () {
                    if (_savedMarkers.containsKey(pharmacy.id.toString())) {
                      mapController.animateCamera(
                        CameraUpdate.newLatLng(LatLng(
                          double.parse(
                              _savedMarkers[pharmacy.id.toString()].split(',')[0]),
                          double.parse(
                              _savedMarkers[pharmacy.id.toString()].split(',')[1]),
                        )),
                      );
                      _searchBarController.close();
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  List<Pharmacy> searchResults(String query) {
    return _pharmacies.where((pharmacy) {
      return pharmacy.name.toLowerCase().contains(query.toLowerCase()) ||
          pharmacy.address.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
