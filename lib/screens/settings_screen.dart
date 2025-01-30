import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:arctic_tern/db_objects/user_info.dart';
import 'package:flutter/material.dart';
import 'package:arctic_tern/constants.dart';
import 'package:workmanager/workmanager.dart';

class SettingsScreen extends StatefulWidget {
  final bool darkMode;

  const SettingsScreen({super.key, required this.darkMode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  @override
  void initState() {
    darkMode = widget.darkMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                      fontSize: 20),
                ),
                Switch(
                  value: darkMode,
                  onChanged: (v) {
                    if (darkMode) {
                      darkMode = false;
                      AdaptiveTheme.of(context).setLight();
                    } else {
                      AdaptiveTheme.of(context).setDark();
                      darkMode = true;
                    }
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
                      AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
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
        iconTheme: IconThemeData(
            color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
        backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
        title: Text(
          'Settings',
          style: TextStyle(
              color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
        ),
        leading: IconButton(
          onPressed: () async {
            await UserInfo.removeUserInfo(darkMode ? 0 : 1);
            await UserInfo(darkMode: darkMode ? 1 : 0).insert();
            if (context.mounted) Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
