import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DropOffPointsScreen extends StatefulWidget {
  const DropOffPointsScreen({super.key});

  @override
  _DropOffPointsScreenState createState() => _DropOffPointsScreenState();
}

class _DropOffPointsScreenState extends State<DropOffPointsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _fetchDropOffPoints();
  }

  Future<void> _fetchDropOffPoints() async {
    QuerySnapshot snapshot = await _firestore.collection('departments').get();

    setState(() {
      _markers = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        var geo = data['Geo'] as GeoPoint;
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(geo.latitude, geo.longitude),
          infoWindow: InfoWindow(title: data['Nome']),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop-Off Points'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0), // Initial position, adjust as needed
          zoom: 12.0,
        ),
        markers: Set.from(_markers),
      ),
    );
  }
}
