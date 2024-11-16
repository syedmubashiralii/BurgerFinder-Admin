import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class LocationPickerPage extends StatefulWidget {
  final Function(LatLng location) onAddLocation;
  LocationPickerPage({required this.onAddLocation});
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng _pickedLocation =
      const LatLng(-12.46, 130.84); // Default location (London)
  String _address = 'Select a location';

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
  }

  double _currentZoom = 15.0;

  // Method to pick the location
  void _pickLocation(LatLng point) async {
    setState(() {
      _pickedLocation = point;
    });
    List<Placemark> placemarks =
        await placemarkFromCoordinates(point.latitude, point.longitude);
    if (placemarks.isNotEmpty) {
      setState(() {
        _address =
            "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
      });
    }
  }

  // Method to get the current user location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _mapController.move(LatLng(position.latitude, position.longitude), 15);
    _pickLocation(LatLng(position.latitude, position.longitude));
  }

   void _zoomIn() {
    if (_currentZoom < 18) {
      _currentZoom++;
      _mapController.move(_pickedLocation, _currentZoom);
      setState(() {});
    }
  }

  // Zoom Out
  void _zoomOut() {
    if (_currentZoom > 5) {
      _currentZoom--;
      _mapController.move(_pickedLocation, _currentZoom);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pickedLocation,
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  _pickLocation(point);
                },
              ),
              children: [
                openStreetMapTileLayer,
                // TileLayer(
                //   tileProvider: AssetTileProvider(),
                //   maxZoom: 14,
                //   urlTemplate:
                //       'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                //   subdomains: ['a', 'b', 'c'],
                //   userAgentPackageName: 'com.example.restaurant_user_admin',
                // ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation,
                      width: 64,
                      height: 64,
                      alignment: Alignment.centerLeft,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      child: const Text(
                        'Use Current Location',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Logic to confirm the selection
                        print('Location selected: $_pickedLocation');
                        widget.onAddLocation(_pickedLocation);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
     floatingActionButton: Padding(
       padding: const EdgeInsets.only(bottom: 50),
       child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _zoomIn,
              child: const CircleAvatar(
                radius: 30, // Size of the circle
                backgroundColor: Colors.teal,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30, // Icon size
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _zoomOut,
              child: const CircleAvatar(
                radius: 30, // Size of the circle
                backgroundColor: Colors.teal,
                child: Icon(
                  Icons.remove,
                  color: Colors.white,
                  size: 30, // Icon size
                ),
              ),
            ),
          ],
        ),
     ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      // Use the recommended flutter_map_cancellable_tile_provider package to
      // support the cancellation of loading tiles.
      tileProvider: CancellableNetworkTileProvider(),
    );
