import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'package:weather_note/constants.dart';
import 'package:weather_note/db_objects/note.dart';
import 'package:weather_note/screens/new_note_screen.dart';
import 'package:weather_note/screens/note_info_screen.dart';
import 'package:weather_note/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];

  List<Color> greyOutIfNotActive(Note note) {
    List<Color> colors = [
      colorScheme.secondary,
      colorScheme.secondary,
      colorScheme.secondary,
      colorScheme.secondary,
    ];

    if (note.timeNotification.isNotEmpty) {
      colors[0] = colorScheme.onSecondary;
    }
    if (note.locationNotification.isNotEmpty) {
      colors[1] = colorScheme.onSecondary;
    }
    if (note.weatherNotification.isNotEmpty) {
      colors[2] = colorScheme.onSecondary;
    }
    if (note.notificationPeriod.isNotEmpty) {
      colors[3] = colorScheme.onSecondary;
    }

    return colors;
  }

  Future<void> getNotes() async {
    final n = await Note.getNotes();
    setState(() {
      notes = n.reversed.toList();
    });
  }

  Future<void> askForPermission() async {
    await Permission.notification
        .onDeniedCallback(() {})
        .onGrantedCallback(() {})
        .onPermanentlyDeniedCallback(() {})
        .onRestrictedCallback(() {})
        .onLimitedCallback(() {})
        .onProvisionalCallback(() {})
        .request();
    await Permission.locationWhenInUse
        .onDeniedCallback(() {})
        .onGrantedCallback(() {})
        .onPermanentlyDeniedCallback(() {})
        .onRestrictedCallback(() {})
        .onLimitedCallback(() {})
        .onProvisionalCallback(() {})
        .request();
  }

  @override
  void initState() {
    askForPermission();
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NewNoteScreen(refreshNotesCallback: getNotes),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: padding, right: padding, top: padding),
            child: TextField(
              maxLines: null,
              onChanged: (String searchQuery) {
                setState(() {
                  // search notes
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(radius),
                  ),
                ),
                hintText: 'Search notes',
                hintStyle: TextStyle(color: colorScheme.onSurface),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(padding),
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                List<Color> iconColors = greyOutIfNotActive(notes[index]);
                return GestureDetector(
                  // animation would be nice here
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteInfoScreen(
                          note: notes[index],
                          refreshNotesCallback: getNotes,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Note'),
                          content: const Text(
                              'Are you sure you want to delete this note? (cannot be undone)'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Note.removeNote(notes[index].title);
                                Workmanager()
                                    .cancelByUniqueName(notes[index].title);
                                getNotes();
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  // Note preview
                  child: Padding(
                    padding: const EdgeInsets.all(halfPadding / 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(radius),
                        ),
                      ),
                      height: 80,
                      child: Padding(
                        padding: const EdgeInsets.all(padding / 3),
                        child: Column(
                          children: [
                            Expanded(
                              child: Text(
                                notes[index].title,
                                style: TextStyle(
                                  fontSize: mediumFontSize,
                                  color: colorScheme.onSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Icon(
                                      Icons.access_time,
                                      color: iconColors[0],
                                    ),
                                  ),
                                  Expanded(
                                    child: Icon(
                                      Icons.pin_drop,
                                      color: iconColors[1],
                                    ),
                                  ),
                                  Expanded(
                                    child: Icon(
                                      Icons.cloud,
                                      color: iconColors[2],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.settings,
              color: colorScheme.onPrimary,
            )),
        backgroundColor: colorScheme.primary,
        // Category selection, home screen
        title: DropdownMenu(
          trailingIcon: Icon(
            Icons.arrow_drop_down,
            color: colorScheme.onPrimary,
          ),
          selectedTrailingIcon: Icon(
            Icons.arrow_drop_up,
            color: colorScheme.onPrimary,
          ),
          menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(colorScheme.primary)),
          textStyle: TextStyle(color: colorScheme.onPrimary),
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
          ),
          initialSelection: 'Category',
          onSelected: (String? category) {},
          dropdownMenuEntries: [
            DropdownMenuEntry(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
              ),
              value: 'Category',
              label: 'Category',
              leadingIcon: Icon(
                Icons.square_rounded,
                color: Colors.white,
              ),
            ), // make sure user cant create category named 'Category' & 'Create', it would cause collision
            DropdownMenuEntry(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
              ),
              value: 'School',
              label: 'School',
              leadingIcon: Icon(
                Icons.square_rounded,
                color: Colors.blue,
              ),
            ),
            DropdownMenuEntry(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
              ),
              value: 'Work',
              label: 'Work',
              leadingIcon: Icon(
                Icons.square_rounded,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
