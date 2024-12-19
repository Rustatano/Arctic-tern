import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/notifications/notification.dart';
import 'package:arctic_tern/screens/home_screen.dart';
import 'package:arctic_tern/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher);
  await startBGTasks();
  await openDatabase(
    version: 1,
    join(await getDatabasesPath(), 'geoNote.db'),
    onConfigure: (db) { // dont close db, it will break things
      db.execute(
        'CREATE TABLE IF NOT EXISTS category(_category TEXT PRIMARY KEY, _r TEXT, _g TEXT, _b TEXT)',
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS note(_title TEXT PRIMARY KEY, _category TEXT, _content TEXT, _dateModified TEXT, _from TEXT, _to TEXT, _location TEXT, _active TEXT)',
      );
    },
  );
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
  int delay = 60 * (((minutes / 5).floor() + 1) * 5 - minutes) - seconds + 5;
  for (var i = 0; i < 3; i++) {
    await Workmanager().registerPeriodicTask(
      "notification_checker${DateTime.now().add(Duration(seconds: i))}",
      "notification_checker${DateTime.now().add(Duration(seconds: i))}",
      frequency: Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      initialDelay: Duration(
        minutes: i * 5,
        seconds: delay,
      ),
    );
  }
}
