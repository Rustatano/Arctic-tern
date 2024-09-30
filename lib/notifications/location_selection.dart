import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_note/constants.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late LatLng currentLocation;
  late AlignOnUpdate alignPositionOnUpdate;
  late final StreamController<double?> alignPositionStreamController;
  Map<String, double> result = {
    'lat': 0.0,
    'long': 0.0,
    'deviation': 10.0,
  };

  @override
  void initState() {
    super.initState();
    alignPositionOnUpdate = AlignOnUpdate.always;
    alignPositionStreamController = StreamController<double?>();
    alignPositionStreamController.add(18);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(0, 0),
          initialZoom: 5,
          onPositionChanged: (MapCamera camera, bool hasGesture) {
            if (hasGesture && alignPositionOnUpdate != AlignOnUpdate.never) {
              setState(
                () => alignPositionOnUpdate = AlignOnUpdate.never,
              );
            }
          },
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
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(padding),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Set deviation:'),
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40,
                                onSelectedItemChanged: (v) {
                                  setState(() {
                                    var tmp = meters[v].child! as Text;
                                    result['deviation'] =
                                        double.parse(tmp.data!);
                                  });
                                },
                                children: meters,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context, result);
                              },
                              child: const Text('Save'),
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
            userAgentPackageName: 'weather_note',
          ),
          CurrentLocationLayer(
            alignPositionStream: alignPositionStreamController.stream,
            alignDirectionOnUpdate: alignPositionOnUpdate,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                onPressed: () {
                  setState(
                    () => alignPositionOnUpdate = AlignOnUpdate.always,
                  );
                  alignPositionStreamController.add(18);
                },
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}
