import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:weather_note/notifications/notification.dart';
import 'package:weather_note/screens/home_screen.dart';
import 'package:weather_note/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherNote',
      theme: themeData,
      home: const HomeScreen(),
    );
  }
}
