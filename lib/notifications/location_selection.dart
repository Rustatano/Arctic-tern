import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  LatLng? latlng;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
        ),
        onTap: (ll) {
          latlng = ll;
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
