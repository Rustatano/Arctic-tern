import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:weather_location_time/db_manipulation.dart';
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
          useMaterial3: true,
        ),
        home: const HomePage());
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
    final n = await getNotesDB();
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
        const Placeholder(),
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: notes.length,
          itemBuilder: (BuildContext context, int index) {
            /*
            GestureDetector(
                onLongPress: () {
                  Dialog(
                    child: Column(
                      children: [
                        const Center(
                          child: Text('Delete this note?'),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },*/
            return Container(
              height: 50,
              color: theme.primaryColorLight,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteInfoPage(note: notes[index]),
                      ),
                    );
                  },
                  child: Text(notes[index].title),
                ),
              ),
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
          title: const Text('All categories'),
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
          title: const Text('All categories'),
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
          title: const Text('All categories'),
          actions: [
            TextButton(
              onPressed: () {
                if (newNote.title.isNotEmpty) {
                  insertNoteDB(newNote);
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
