import 'package:flutter/material.dart';

import 'package:weather_location_time/db_objects/note.dart';
import 'package:weather_location_time/note_info_screen.dart';
import 'package:weather_location_time/settings_page.dart';

void main() {
  runApp(const MyApp());
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
  static const padding = 24.0;
  static const radius = 16.0;
  Note newNote = Note.toDefault();
  List<Note> notes = [];
  TextEditingController contentTextFieldController = TextEditingController();
  TextEditingController titleTextFieldController = TextEditingController();

  Future<void> getNotes() async {
    final n = await Note.getNotes();
    setState(() {
      notes = n.reversed.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    

    return PageView(
      children: [
        Scaffold(
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
                      child: Padding(
                        padding: const EdgeInsets.all(padding / 4),
                        child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(radius),
                              ),
                            ),
                            height: 54,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(notes[index].title),
                            )),
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
          body: Padding(
            padding: const EdgeInsets.all(padding),
            child: ListView(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - padding * 2,
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
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.access_time),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.pin_drop),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.cloud),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - padding * 2,
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
                      getNotes();
                      contentTextFieldController.clear();
                      titleTextFieldController.clear();
                      newNote = Note.toDefault();
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
