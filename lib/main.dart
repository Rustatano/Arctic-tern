import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/notifications/notification.dart';
import 'package:arctic_tern/screens/home_screen.dart';
import 'package:arctic_tern/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arctic tern',
      theme: themeData,
      home: const HomeScreen(),
    );
  }
}
