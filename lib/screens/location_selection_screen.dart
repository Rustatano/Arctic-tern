import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:arctic_tern/db_objects/saved_location.dart';
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
  Map<String, dynamic> result = {
    'lat': 0.0,
    'long': 0.0,
    'radius': 10,
  };
  List<Marker> markers = [];
  bool saveLocation = false;
  TextEditingController locationNameTextFieldController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.surface,
      body: FutureBuilder(
        future: currentPosition,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Position position = snapshot.data!;
            markers.add(
              Marker(
                point: LatLng(position.latitude, position.longitude),
                child: Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
              ),
            );
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
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) {
                        return Dialog(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: 300,
                            height: 270,
                            child: Padding(
                              padding: const EdgeInsets.all(padding),
                              child: Column(
                                children: [
                                  Text(
                                    'Set radius:',
                                    style: TextStyle(
                                      color: AdaptiveTheme.of(context)
                                          .theme
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      itemExtent: 40,
                                      onSelectedItemChanged: (v) {
                                        setState(() { // TODO, BUG: radius is not saving correctly
                                          result['radius'] = int.parse(
                                              (meters[v].child! as Text).data!);
                                        });
                                      },
                                      children: meters,
                                    ),
                                  ),
                                  const Text('Save this location'),
                                  Switch(
                                    value: saveLocation,
                                    onChanged: (_) {
                                      setState(() {
                                        saveLocation = !saveLocation;
                                      });
                                    },
                                  ),
                                  Builder(builder: (_) {
                                    if (saveLocation) {
                                      return TextField(
                                        controller:
                                            locationNameTextFieldController,
                                        decoration: InputDecoration(
                                            hintText: 'Location name'),
                                        cursorColor: AdaptiveTheme.of(context)
                                            .theme
                                            .colorScheme
                                            .onSurface,
                                      );
                                    }
                                    return Divider(
                                      height: 0,
                                      color: AdaptiveTheme.of(context)
                                          .theme
                                          .colorScheme
                                          .onSurface,
                                    );
                                  }),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {
                                              markers = [
                                                markers.first
                                              ]; // .removeLast doesn't work for some reason
                                            });
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: AdaptiveTheme.of(context)
                                                  .theme
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                            if (saveLocation &&
                                                locationNameTextFieldController
                                                    .text.isNotEmpty) {
                                              await SavedLocation(
                                                name:
                                                    locationNameTextFieldController
                                                        .text,
                                                location:
                                                    '{"latitude": "${result['lat']}", "longitude": "${result['long']}"}',
                                                radius: result['radius'],
                                              ).insert();
                                            }
                                            if (!context.mounted) return;
                                            Navigator.pop(context);
                                            Navigator.pop(context, result);
                                          },
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                              color: AdaptiveTheme.of(context)
                                                  .theme
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                  setState(() {
                    markers.add(
                      Marker(
                        alignment: Alignment.topCenter,
                        point: point,
                        child: GestureDetector(
                          child: Icon(
                            Icons.place,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  });
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
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(padding),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .primary,
                          ),
                          width: 50,
                          height: 50,
                          child: IconButton(
                            onPressed: () async {
                              List<SavedLocation> savedLocations =
                                  await SavedLocation.getSavedLocation();
                              if (!context.mounted) return;
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: 300,
                                    height: 200,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(halfPadding),
                                      child: (savedLocations.isNotEmpty)
                                          ? ListView.builder(
                                              itemCount: savedLocations.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Map<String, dynamic>
                                                        coordinates =
                                                        JsonDecoder().convert(
                                                      savedLocations[index]
                                                          .location,
                                                    );
                                                    setState(() {
                                                      result['lat'] =
                                                          coordinates[
                                                              'latitude'];
                                                      result['long'] =
                                                          coordinates[
                                                              'longitide'];
                                                    });
                                                    Navigator.pop(context);
                                                    Navigator.pop(
                                                        context, result);
                                                  },
                                                  onLongPress: () {
                                                    SavedLocation
                                                        .removeSavedLocation(
                                                            savedLocations[
                                                                    index]
                                                                .name);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            halfPadding),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AdaptiveTheme.of(
                                                                context)
                                                            .theme
                                                            .colorScheme
                                                            .primary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          '${savedLocations[index].name}\n${savedLocations[index].location}',
                                                          style: TextStyle(
                                                            color: AdaptiveTheme
                                                                    .of(context)
                                                                .theme
                                                                .colorScheme
                                                                .onPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : Center(
                                              child: Text(
                                                'This is where are your saved locations',
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.place,
                              color: AdaptiveTheme.of(context)
                                  .theme
                                  .colorScheme
                                  .onPrimary,
                            ),
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: padding,
                          left: padding,
                          bottom: padding,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .primary,
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
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: padding, left: padding),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .primary,
                          ),
                          width: 50,
                          height: 50,
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
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .primary,
                          ),
                        ),
                      ),
                    ],
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
