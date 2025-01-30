import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:arctic_tern/db_objects/user_info.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/notifications/notification.dart';
import 'package:arctic_tern/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher);
  await startBGTasks();
  await openDatabase(
    version: 1,
    join(await getDatabasesPath(), 'geoNote.db'),
    onConfigure: (db) {
      // dont close db, it will break things
      db.execute(
        'CREATE TABLE IF NOT EXISTS category(_category TEXT PRIMARY KEY, _r TEXT, _g TEXT, _b TEXT)',
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS note(_title TEXT PRIMARY KEY, _category TEXT, _content TEXT, _dateModified TEXT, _from TEXT, _to TEXT, _location TEXT, _active TEXT)',
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS userInfo(_darkMode INTEGER PRIMARY KEY)',
      );
    },
  );
  if ((await UserInfo.getUserInfo()).isEmpty) {
    UserInfo(darkMode: 0).insert();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;

@override
  void initState() {
    getDarkMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          surface: Colors.white,
          primary: const Color.fromARGB(255, 13, 99, 109),
          onPrimary: Colors.white,
          secondary: const Color.fromARGB(255, 7, 114, 125),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          onSurface: Colors.black,
          surfaceDim: const Color.fromARGB(255, 117, 117, 117),
        ),
        useMaterial3: true,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 30, 30, 30),
          primary: const Color.fromARGB(255, 13, 99, 109),
          onPrimary: Colors.white,
          secondary: const Color.fromARGB(255, 7, 114, 125),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          onSurface: Colors.white,
          surfaceDim: const Color.fromARGB(255, 117, 117, 117),
        ),
        useMaterial3: true,
      ),
      initial: (darkMode) ? AdaptiveThemeMode.dark : AdaptiveThemeMode.light,
      builder: (light, dark) => MaterialApp(
        title: 'GeoNote',
        home: const HomeScreen(),
      ),
    );
  }

  Future<void> getDarkMode() async {
    final darkMode = (await UserInfo.getUserInfo()).first.darkMode == 1;
    setState(() {
      this.darkMode = darkMode;
    });
  }
}

Future<void> startBGTasks() async {
  int seconds = DateTime.now().second;
  int minutes = DateTime.now().minute;
  int delay = 60 * (((minutes / 5).floor() + 1) * 5 - minutes) - seconds + 5;
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
