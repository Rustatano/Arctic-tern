import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_location_time/constants.dart';

import 'package:workmanager/workmanager.dart';

import 'package:weather_location_time/db_objects/note.dart';
import 'package:weather_location_time/note_info_screen.dart';
import 'package:weather_location_time/notification_screens/time_notification.dart';
import 'package:weather_location_time/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcherTimeNotification);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcherTimeNotification() {
  Workmanager().executeTask(
    (task, inputData) async {
      WidgetsFlutterBinding.ensureInitialized();
      await TimeNotification().showTimeNotification(
          title: inputData?['title'], body: inputData?['content']);
      inputData!['timeNotification'] = inputData['timeNotification'] = '';
      await Note.removeNote(inputData['title']);
      Note note = Note.fromMap(inputData);
      await note.insertIfNotExists();

      return Future.value(true);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Note',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 255, 191),
          primary: const Color.fromARGB(255, 0, 255, 191),
          secondary: const Color.fromARGB(255, 160, 255, 231),
          onPrimary: Colors.black,
          background: const Color.fromARGB(255, 255, 240, 255),
          tertiary: const Color.fromARGB(255, 0, 100, 80),
        ),
        useMaterial3: true,
      ),
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

  List<Color> greyOutIfNotActive(Note note) {
    final ThemeData theme = Theme.of(context);

    List<Color> colors = [
      theme.colorScheme.secondary,
      theme.colorScheme.secondary,
      theme.colorScheme.secondary,
    ];

    if (note.timeNotification.isNotEmpty) {
      colors[0] = theme.colorScheme.tertiary;
    }
    if (note.locationNotification.isNotEmpty) {
      colors[1] = theme.colorScheme.tertiary;
    }
    if (note.weatherNotification.isNotEmpty) {
      colors[2] = theme.colorScheme.tertiary;
    }

    return colors;
  }

  Color greyOutIfNotActiveEditScreen(Note note, String notification) {
    final ThemeData theme = Theme.of(context);
    if (note.toMap()[notification] == '') {
      return theme.colorScheme.background;
    } else {
      return theme.colorScheme.onPrimary;
    }
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
  }

  @override
  void initState() {
    askForPermission();
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return PageView(
      children: [
        Scaffold(
          backgroundColor: theme.colorScheme.background,
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(radius),
                      ),
                    ),
                    hintText: 'Search notes',
                    prefixIcon: Icon(Icons.search),
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
                            color: theme.colorScheme.secondary,
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
                                    style: const TextStyle(
                                        fontSize: mediumFontSize),
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
                                )
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
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings)),
            backgroundColor: theme.colorScheme.primary,
            title: DropdownMenu(
              inputDecorationTheme: const InputDecorationTheme(
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
          ),
        ),
        Scaffold(
          backgroundColor: theme.colorScheme.background,
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter a note title',
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    DropdownMenu(
                      inputDecorationTheme: const InputDecorationTheme(
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
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final date =
                                  await showDateTimePicker(context: context, initialDate: newNote.timeNotification);
                              setState(() {
                                newNote.timeNotification = '';
                              });
                              if (date != null) {
                                setState(() {
                                  newNote.timeNotification =
                                      date.toString().substring(0, 16);
                                });
                              }
                            },
                            icon: const Icon(Icons.access_time),
                          ),
                          Text(
                            newNote.timeNotification,
                            style: const TextStyle(fontSize: smallFontSize),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.pin_drop),
                          ),
                          Text(newNote.locationNotification),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.cloud),
                          ),
                          Text(newNote.weatherNotification),
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Start typing here',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primary,
            title: const Text('New Note'),
            actions: [
              TextButton(
                onPressed: () async {
                  newNote.trimProperties();
                  if (newNote.title.isNotEmpty) {
                    if (await newNote.insertIfNotExists()) {
                      if (newNote.timeNotification.isNotEmpty) {
                        int delay = ((DateTime.parse(newNote.timeNotification)
                                        .millisecondsSinceEpoch -
                                    DateTime.now().millisecondsSinceEpoch) /
                                1000)
                            .round();
                        Workmanager().registerOneOffTask(
                          newNote.title,
                          newNote.title,
                          initialDelay: Duration(seconds: delay),
                          inputData: newNote.toMap(),
                        );
                      }
                      contentTextFieldController.clear();
                      titleTextFieldController.clear();
                      newNote = Note.toDefault();
                      getNotes();
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
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('Error'),
                        content: Text('Note title is required'),
                      ),
                    );
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
