import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final List<LatLng> _markerPositions = [
    LatLng(37.42796133580664, -122.085749655962), // Original position
    LatLng(37.8021, -122.4186), // Coit Tower, San Francisco
    LatLng(37.8087, -122.4098), // Pier 39, San Francisco
    LatLng(37.8078, -122.4174), // Fisherman's Wharf, San Francisco
    LatLng(37.8199, -122.4783), // Golden Gate Bridge, San Francisco
    LatLng(37.8024, -122.4057), // Lombard Street, San Francisco
    LatLng(37.7694, -122.4862), // Golden Gate Park, San Francisco
    LatLng(37.7941, -122.4078), // Union Square, San Francisco
    // Add more LatLng positions here if needed
  ];

  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _markers = _markerPositions
          .map((position) => Marker(
                markerId: MarkerId(position.toString()),
                position: position,
              ))
          .toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _markerPositions.last,
          zoom: 12.0,
        ),
        markers: _markers,
      ),
    );
  }
}
