import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'package:weather_note/constants.dart';
import 'package:weather_note/screens/location_selection_screen.dart';
import 'package:weather_note/db_objects/note.dart';
import 'package:weather_note/screens/note_info_screen.dart';
import 'package:weather_note/notifications/notification.dart';
import 'package:weather_note/screens/settings_screen.dart';

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
      title: 'Weather Note',
      theme: themeData,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Note newNote = Note.toDefault();
  List<Note> notes = [];
  TextEditingController contentTextFieldController = TextEditingController();
  TextEditingController titleTextFieldController = TextEditingController();
  bool checkBoxValue = false;
  bool isTimeNotificationSelected = false;

  List<Color> greyOutIfNotActive(Note note) {
    List<Color> colors = [
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
    return PageView(
      children: [
        Scaffold(
          backgroundColor: colorScheme.surface,
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
                    prefixIcon:
                        Icon(Icons.search, color: colorScheme.onSurface),
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
                          height: doublePadding,
                          child: Padding(
                            padding: const EdgeInsets.all(padding / 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notes[index].title,
                                    style: TextStyle(
                                        fontSize: mediumFontSize,
                                        color: colorScheme.onSecondary),
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
                  backgroundColor:
                      WidgetStateProperty.all(colorScheme.primary)),
              textStyle: TextStyle(color: colorScheme.onPrimary),
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none,
              ),
              initialSelection: 'Category',
              onSelected: (String? category) {
                setState(() {
                  newNote.category = category!;
                });
              },
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: 'Category',
                  label: 'Category',
                  leadingIcon: Icon(
                    Icons.square,
                    color: Colors.white,
                  ),
                ), // make sure user cant create category named 'Category' & 'Create', it would cause collision
                DropdownMenuEntry(
                  value: 'School',
                  label: 'School',
                  leadingIcon: Icon(
                    Icons.square,
                    color: Colors.blue,
                  ),
                ),
                DropdownMenuEntry(
                  value: 'Work',
                  label: 'Work',
                  leadingIcon: Icon(
                    Icons.square,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: colorScheme.surface,
          body: Padding(
            padding: const EdgeInsets.all(padding),
            child: ListView(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - doublePadding,
                      child: TextField(
                        controller: titleTextFieldController,
                        maxLines: null,
                        onChanged: (String title) {
                          setState(() {
                            newNote.title = title;
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter a note title',
                          hintStyle:
                              TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    // Category selection, new note
                    DropdownMenu(
                      trailingIcon: Icon(
                        Icons.arrow_drop_down,
                        color: colorScheme.onPrimary,
                      ),
                      selectedTrailingIcon: Icon(
                        Icons.arrow_drop_up,
                        color: colorScheme.onPrimary,
                      ),
                      menuStyle: MenuStyle(
                          backgroundColor: WidgetStateProperty.all(
                              colorScheme.primary)),
                      inputDecorationTheme: InputDecorationTheme(
                        border: InputBorder.none,
                      ),
                      initialSelection: 'Category',
                      onSelected: (String? category) {
                        setState(() {
                          newNote.category = category!;
                        });
                      },
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(
                          value: 'Category',
                          label: 'Category',
                          leadingIcon: Icon(
                            Icons.square,
                            color: Colors.white,
                          ),
                        ), // make sure user cant create category named 'Category' & 'Create', it would cause collision
                        DropdownMenuEntry(
                          value: 'School',
                          label: 'School',
                          leadingIcon: Icon(
                            Icons.square,
                            color: Colors.blue,
                          ),
                        ),
                        DropdownMenuEntry(
                          value: 'Work',
                          label: 'Work',
                          leadingIcon: Icon(
                            Icons.square,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    // time notification
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final date = await showDateTimePicker(
                                  context: context,
                                  initialDate: newNote.timeNotification);
                              setState(() {
                                newNote.timeNotification = '';
                              });
                              if (date != null) {
                                setState(() {
                                  newNote.timeNotification =
                                      date.toString().substring(0, 16);
                                  isTimeNotificationSelected = true;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.access_time,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            newNote.timeNotification,
                            style: const TextStyle(fontSize: smallFontSize),
                          ),
                        ],
                      ),
                    ),
                    // location notification
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: (isTimeNotificationSelected)
                                ? () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LocationSelectionScreen(),
                                      ),
                                    );
                                    setState(() {
                                      newNote.locationNotification =
                                          (result != null)
                                              ? jsonEncode(result)
                                              : '';
                                    });
                                  }
                                : () => {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const AlertDialog(
                                          title: Text('Note'),
                                          content: Text(
                                            'You must select time notification first',
                                          ),
                                        ),
                                      )
                                    },
                            icon: Icon(
                              Icons.pin_drop,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(newNote.locationNotification),
                        ],
                      ),
                    ),
                    // weather notification
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: (isTimeNotificationSelected)
                                ? () {}
                                : () => {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const AlertDialog(
                                          title: Text('Note'),
                                          content: Text(
                                            'You must select time notification first',
                                          ),
                                        ),
                                      )
                                    },
                            icon: Icon(
                              Icons.cloud,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(newNote.weatherNotification),
                        ],
                      ),
                    ),
                    // repeat notification
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () async {
                              List<Padding> timeScale = const [
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text('months'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text('days'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text('hours'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text('minutes'),
                                ),
                              ];
                              List<Widget> timeCount = [];
                              for (var i = 1; i < 24; i++) {
                                timeCount.add(Text(i.toString()));
                              }
                              int selectedTimeScale = 0;
                              int selectedTimeCount = 1;
                              await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: SizedBox(
                                    width: 300, // make this adaptable
                                    height: 200,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: padding, bottom: padding),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: CupertinoPicker(
                                                  // inspiritaion in notifications on my phone
                                                  itemExtent: 30,
                                                  onSelectedItemChanged: (val) {
                                                    selectedTimeScale = val;
                                                  },
                                                  children: timeScale,
                                                ),
                                              ),
                                              Expanded(
                                                child: CupertinoPicker(
                                                  itemExtent: 30,
                                                  onSelectedItemChanged: (val) {
                                                    selectedTimeCount = val;
                                                  },
                                                  children: timeCount,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Save'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                selectedTimeScale = 10;
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              // approximate, do this exact
                              setState(() {
                                selectedTimeCount++;
                                switch (selectedTimeScale) {
                                  case 0:
                                    newNote.notificationPeriod =
                                        (2629800 * selectedTimeCount)
                                            .toString();
                                    break;
                                  case 1:
                                    newNote.notificationPeriod =
                                        (86400 * selectedTimeCount).toString();
                                    break;
                                  case 2:
                                    newNote.notificationPeriod =
                                        (3600 * selectedTimeCount).toString();
                                    break;
                                  case 3:
                                    newNote.notificationPeriod =
                                        (60 * selectedTimeCount).toString();
                                    break;
                                  default:
                                    newNote.notificationPeriod = '';
                                    break;
                                }
                              });
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(newNote.notificationPeriod),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - doublePadding,
                      child: TextField(
                        controller: contentTextFieldController,
                        maxLines: null,
                        onChanged: (String content) {
                          setState(() {
                            newNote.content = content;
                          });
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Start typing here',
                            hintStyle:
                                TextStyle(color: colorScheme.onSurface)),
                        cursorColor: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            title: Text(
              'New Note',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  newNote.trimProperties();
                  if (newNote.title.isNotEmpty) {
                    if (await newNote.insertIfNotExists()) {
                      if (newNote.timeNotification.isNotEmpty ||
                          newNote.notificationPeriod.isNotEmpty) {
                        Duration? frequency;
                        int delay = 0;
                        if (newNote.notificationPeriod != '') {
                          frequency = Duration(
                              seconds: int.parse(newNote.notificationPeriod));
                        }
                        if (newNote.timeNotification.isNotEmpty) {
                          delay = ((DateTime.parse(newNote.timeNotification)
                                          .millisecondsSinceEpoch -
                                      DateTime.now().millisecondsSinceEpoch) /
                                  1000)
                              .round();
                        }

                        Workmanager().registerPeriodicTask(
                          newNote.title,
                          newNote.title,
                          initialDelay: Duration(seconds: delay),
                          inputData: newNote.toMap(),
                          frequency: frequency,
                        );
                      }
                      setState(() {
                        contentTextFieldController.clear();
                        titleTextFieldController.clear();
                        newNote = Note.toDefault();
                        isTimeNotificationSelected = false;
                        getNotes();
                      });
                    } else {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            title: Text('Error'),
                            content: Text(
                                'Note title already exists. Notes cannot have the same titles'),
                          ),
                        );
                      }
                    }
                  } else {
                    newNote.title = '(no title)';
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
