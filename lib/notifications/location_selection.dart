import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  Map<String, String> latlng = {
    'lat': '',
    'lng': '',
    'deviation': '',
  };
  int deviation = 10;
  LatLng currentLocation = const LatLng(0, 0);
  Set<Marker> markers = {};

  Future<void> getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: GoogleMap(
        markers: markers,
        myLocationEnabled: true,
        onMapCreated: (controller) async {
          await getCurrentLocation();
          controller
              .moveCamera(CameraUpdate.newLatLngZoom(currentLocation, 10));
        },
        initialCameraPosition: CameraPosition(
          target: currentLocation,
        ),
        onTap: (ll) {
          // on tap, show pin. Above that pin, show a widget, where the user will be able to set deviation.
          //Remove 'Save in top right' and add save button to the widget above the pin.
          latlng['lat'] = ll.latitude.toString();
          latlng['lng'] = ll.longitude.toString();
          setState(() {
            markers.clear();
            markers.add(
              Marker(
                  markerId: const MarkerId('locationSelectionMarker'),
                  position: ll),
            );
          });
        },
      ),
      appBar: AppBar(
        title: const Text('Select location'),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          TextButton(
            onPressed: () {
              // show pin
              Navigator.pop(context, latlng);
            },
            child: Text(
              'Save',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          )
        ],
      ),
    );
  }
}
