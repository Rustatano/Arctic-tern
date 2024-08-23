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
  Map<String, String> latlng = {
    'lat': '',
    'lng': '',
    'deviation': '',
  };
  int deviation = 10;
  //late LatLng currentLocation;

  @override
  void initState() {
    super.initState();
    //getCurrentLocation();
  }

  /*Future<void> getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
        ),
        onTap: (ll) {
          // on tap, show pin. Above that pin, show a widget, where the user will be able to set deviation.
          //Remove 'Save in top right' and add save button to the widget above the pin.
          latlng['lat'] = ll.latitude.toString();
          latlng['lng'] = ll.longitude.toString();
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
