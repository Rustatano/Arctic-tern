import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:arctic_tern/constants.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  Future<Position> currentPosition = Geolocator.getCurrentPosition();
  MapController mapController = MapController();
  Map<String, double> result = {
    'lat': 0.0,
    'long': 0.0,
    'radius': 10.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.surface,
      body: FutureBuilder(
        future: currentPosition,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Position position = snapshot.data!;
            List<Marker> markers = [
              Marker(
                point: LatLng(position.latitude, position.longitude),
                child: Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
              ),
            ];
            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(position.latitude, position.longitude),
                initialZoom: 15,
                onTap: (tapPosition, point) {
                  result['lat'] = point.latitude;
                  result['long'] = point.longitude;
                  List<Center> meters = [];
                  for (var i = 10; i < 1000; i += 10) {
                    meters.add(
                      Center(
                        child: Text(
                          i.toString(),
                        ),
                      ),
                    );
                  }
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: SizedBox(
                        width: 300,
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(padding),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text('Set radius:'),
                                  Expanded(
                                    child: CupertinoPicker(
                                      itemExtent: 40,
                                      onSelectedItemChanged: (v) {
                                        setState(() {
                                          var text = meters[v].child! as Text;
                                          result['radius'] =
                                              double.parse(text.data!);
                                        });
                                      },
                                      children: meters,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context, result);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.arctic_tern.app',
                ),
                MarkerLayer(markers: markers),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(padding),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:
                            AdaptiveTheme.of(context).theme.colorScheme.primary,
                      ),
                      width: 70,
                      height: 70,
                      child: IconButton(
                        onPressed: () {
                          mapController.moveAndRotate(
                            LatLng(
                              position.latitude,
                              position.longitude,
                            ),
                            15,
                            0,
                          );
                        },
                        icon: Icon(
                          Icons.my_location,
                          color: AdaptiveTheme.of(context)
                              .theme
                              .colorScheme
                              .onPrimary,
                        ),
                        color:
                            AdaptiveTheme.of(context).theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color:
                            AdaptiveTheme.of(context).theme.colorScheme.primary,
                      ),
                      width: 50,
                      height: 50,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            mapController.rotate(0);
                          });
                        },
                        icon: Icon(
                          CupertinoIcons.compass,
                          color: AdaptiveTheme.of(context)
                              .theme
                              .colorScheme
                              .onPrimary,
                        ),
                        color:
                            AdaptiveTheme.of(context).theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: doublePadding),
                    child: Text(
                      'Loading the map...',
                      style: TextStyle(
                        color: AdaptiveTheme.of(context)
                            .theme
                            .colorScheme
                            .onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      appBar: AppBar(
        title: Text(
          'Select Location',
          style: TextStyle(
              color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
        ),
        backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
        iconTheme: IconThemeData(
            color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
      ),
    );
  }
}
