import 'package:flutter/material.dart';

import 'package:weather_location_time/db_objects/note.dart';
import 'package:weather_location_time/note_info_page.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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
  int currentPageIndex = 1;
  NoteDB newNote = NoteDB(
    title: '',
    category: '',
    content: '',
    dateModified: '',
    timeNotification: '',
    locationNotification: '',
    weatherNotification: '',
  );
  List<NoteDB> notes = [];

  Future<void> getNotes() async {
    final n = await NoteDB.getNotesDB();
    setState(() {
      notes = n;
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

    return Scaffold(
      body: <Widget>[
        const Center(
          child: Text('coming soon'),
        ),
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: notes.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              // animation would be nice here
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteInfoPage(note: notes[index]),
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
                          'Are you sure you want to delete this note?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            notes[index].removeNoteDB();
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
              child: Container(
                  color: theme.primaryColorLight,
                  height: 50,
                  child: Center(child: Text(notes[index].title))),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
        Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 300, // make this dynamic size
                  child: TextField(
                    onChanged: (String title) {
                      setState(() {
                        newNote.title = title;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a note title',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Choose category: '),
                DropdownMenu<String>(
                  initialSelection: 'none',
                  onSelected: (String? category) {
                    setState(() {
                      newNote.category = category!;
                    });
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(
                      value: 'none',
                      label: 'none',
                      leadingIcon: Icon(
                        Icons.square,
                        color: Colors.white,
                      ),
                    ), // make sure user cant create category named 'none', it would cause collision
                    DropdownMenuEntry(
                      value: 'school',
                      label: 'school',
                      leadingIcon: Icon(
                        Icons.square,
                        color: Colors.blue,
                      ),
                    ),
                    DropdownMenuEntry(
                      value: 'work',
                      label: 'work',
                      leadingIcon: Icon(
                        Icons.square,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 300, // make this dynamic size
                  child: TextField(
                    maxLines: null,
                    onChanged: (String content) {
                      setState(() {
                        newNote.content = content;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter note',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ][currentPageIndex],
      appBar: [
        AppBar(
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
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: const Text('Search'),
        ),
        AppBar(
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
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: const Text(
              'All Categories'), // make this drop down menu to select displayed category
        ),
        AppBar(
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
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: const Text('New Note'),
          actions: [
            TextButton(
              onPressed: () {
                if (newNote.title.isNotEmpty) {
                  newNote.insertNoteDB();
                  getNotes();
                  currentPageIndex = 1;
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.cyan,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add),
            label: 'New',
          ),
        ],
      ),
    );
  }
}
