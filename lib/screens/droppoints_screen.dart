import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_theme.dart';
import 'login_screen.dart';

class DropOffPointsScreen extends StatefulWidget {
  const DropOffPointsScreen({super.key});

  @override
  _DropOffPointsScreenState createState() => _DropOffPointsScreenState();
}

class CustomMarker {
  final Marker marker;
  final Map<String, dynamic> additionalData;
  String? localImagePath;

  CustomMarker({required this.marker, required this.additionalData, this.localImagePath});
}

class _DropOffPointsScreenState extends State<DropOffPointsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  List<CustomMarker> _allMarkers = [];
  List<CustomMarker> _selectedMarkers = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchDropOffPoints();
    _getUserLocation();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName =
          prefs.getString('name') ?? 'User Name'; // Default name if not found
      _userEmail = prefs.getString('email') ??
          'user@example.com'; // Default email if not found
    });
  }

  Future<void> _fetchDropOffPoints() async {
    QuerySnapshot snapshot = await _firestore.collection('departments').get();
    var newMarkers = <CustomMarker>[];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var geo = data['Geo'] as GeoPoint;
      Marker marker = Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(geo.latitude, geo.longitude),
        infoWindow: InfoWindow(title: data['Nome']),
      );

      // New code starts here
      String imageUrl = data['image'] ?? '';
      String fileName = path.basename(imageUrl);
      String? localImagePath = await _getLocalImagePath(imageUrl);

      if (localImagePath == null && imageUrl.isNotEmpty) {
        localImagePath = await _downloadAndSaveImage(imageUrl, fileName);
      }

      newMarkers.add(CustomMarker(marker: marker, additionalData: data, localImagePath: localImagePath));
    }

    setState(() {
      _allMarkers = newMarkers;
    });
  }

  Future<String?> _getLocalImagePath(String imageUrl) async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    String fileName = path.basename(imageUrl);
    File localFile = File(path.join(documentDirectory.path, fileName));

    return localFile.existsSync() ? localFile.path : null;
  }

  Future<String> _downloadAndSaveImage(String imageUrl, String fileName) async {
    var response = await http.get(Uri.parse(imageUrl));
    var documentDirectory = await getApplicationDocumentsDirectory();
    File file = File(path.join(documentDirectory.path, fileName));
    file.writeAsBytesSync(response.bodyBytes);
    return file.path;
  }


  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle location service not enabled
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // Handle permission denied forever
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle permission denied
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_userLocation != null && _selectedMarkers.isNotEmpty) {
      var firstDropOffPoint = _selectedMarkers.first.marker.position;
      _updateCameraPosition(firstDropOffPoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Drop-Off Points'),
          backgroundColor: const Color(0xFFcab6aa),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(_userName),
                accountEmail: Text(_userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0] : "U",
                    style: const TextStyle(fontSize: 40.0),
                  ),
                ),
                decoration: const BoxDecoration(color: Color(0xFFcab6aa)),
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Items List'),
                onTap: () {
                  // Navigate to Items List
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_problem),
                title: const Text('Report Lost Item'),
                onTap: () {
                  // Navigate to Report Lost Item
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Navigate to Settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            // Close the dialog
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Clear user data or handle logout logic
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        key: _scaffoldKey,
        body: Container(
            color: appTheme.colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: _allMarkers.length,
                itemBuilder: (context, index) {
                  var customMarker = _allMarkers[index];
                  return Card(
                    elevation: 8.0,
                    margin: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: appTheme.colorScheme.primary.withOpacity(0.45),
                    // Single color for the card
                    child: ExpansionTile(
                      leading: customMarker.localImagePath != null
                          ? Image.file(File(customMarker.localImagePath!), width: 50, height: 50)
                          : (customMarker.additionalData['image']?.isNotEmpty ?? false)
                          ? Image.network(customMarker.additionalData['image'], width: 50, height: 50)
                          : const Icon(Icons.location_on, size: 50.0, color: Colors.white),
                      title: Text(
                        customMarker.marker.infoWindow.title ?? '',
                        style: appTheme.textTheme.headlineMedium,
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white),
                      onExpansionChanged: (bool expanded) {
                        if (expanded) {
                          _updateMarkersAndCamera(customMarker.marker);
                        }
                      },
                      children: [
                        SizedBox(
                          height: 200,
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _userLocation ??
                                  const LatLng(
                                      40.630879814996, -8.657001829983233),
                              // Default or current location
                              zoom: 15.0,
                            ),
                            myLocationEnabled: true,
                            // Enable the blue dot
                            myLocationButtonEnabled: true,
                            // Enable location button for centering map on current location
                            markers: Set.from(
                                _selectedMarkers.map((customMarker) => Marker(
                                      markerId: customMarker.marker.markerId,
                                      position: customMarker.marker.position,
                                      icon: BitmapDescriptor
                                          .defaultMarkerWithHue(BitmapDescriptor
                                              .hueOrange), // Change marker icon
                                    ))),
                            mapType: MapType.normal,
                            // Apply custom map style if needed
                            zoomControlsEnabled: false, // Remove zoom controls
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )),
        bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  void _updateMarkersAndCamera(Marker marker) {
    // Find the CustomMarker instance that matches the marker
    var selectedCustomMarker = _allMarkers.firstWhere(
      (customMarker) => customMarker.marker.markerId == marker.markerId,
      orElse: () => CustomMarker(marker: marker, additionalData: {}),
    );

    setState(() {
      // Update the _selectedMarkers list with only the selected CustomMarker
      _selectedMarkers = [selectedCustomMarker];
    });

    // Update camera position
    _updateCameraPosition(marker.position);
  }

  void _updateCameraPosition(LatLng dropOffPoint) {
    if (_userLocation == null) return;

    LatLngBounds bounds;
    double southWestLatitude =
        min(_userLocation!.latitude, dropOffPoint.latitude);
    double southWestLongitude =
        min(_userLocation!.longitude, dropOffPoint.longitude);
    double northEastLatitude =
        max(_userLocation!.latitude, dropOffPoint.latitude);
    double northEastLongitude =
        max(_userLocation!.longitude, dropOffPoint.longitude);

    bounds = LatLngBounds(
      southwest: LatLng(southWestLatitude, southWestLongitude),
      northeast: LatLng(northEastLatitude, northEastLongitude),
    );

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController?.animateCamera(cameraUpdate);
  }

  Widget _buildBottomNavigationBar() {

    return BottomNavigationBar(
      backgroundColor: const Color(0xFFcab6aa),
      selectedItemColor: appTheme.colorScheme.primary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
