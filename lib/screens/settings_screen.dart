import 'package:flutter/material.dart';
import 'package:arctic_tern/constants.dart';
import 'package:workmanager/workmanager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 20),
                ),
                Switch(
                  value: darkMode,
                  onChanged: (v) {
                    setState(() {
                      if (v) {
                        themeData = darkThemeData;
                      } else {
                        themeData = ligthThemeData;
                      }
                      darkMode = v;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Workmanager().cancelAll();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      colorScheme.onPrimary,
                    ),
                  ),
                  child: Text('Cancel all background tasks'),
                ),
              ],
            ),
          ], // dark mode, color theme
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
        title: Text(
          'Settings',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}
