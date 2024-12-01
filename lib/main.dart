import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/notifications/notification.dart';
import 'package:arctic_tern/screens/home_screen.dart';
import 'package:arctic_tern/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher);
  await startBGTasks();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoNote',
      theme: themeData,
      home: const HomeScreen(),
    );
  }
}

Future<void> startBGTasks() async {
    int seconds = DateTime.now().second;
    int minutes = DateTime.now().minute;
    int delay = 60 * (((minutes / 5).floor() + 1) * 5 - minutes) - seconds;
    for (var i = 0; i < 3; i++) {
      await Workmanager().registerPeriodicTask(
        "notification_checker$i",
        "notification_checker$i",
        frequency: Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        initialDelay: Duration(
          minutes: i * 5,
          seconds: delay,
        ),
      );
    }
  }
