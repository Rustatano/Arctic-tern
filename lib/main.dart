import 'package:flutter/material.dart';

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
  String title = '';
  String selectedTitle = '';
  String selectedCategory = 'none';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      drawer: const Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [Text('school'), Text('work'), Text('free time')],
        ),
      ),
      body: <Widget>[
        const Placeholder(),
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: 40,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 50,
              color: theme.primaryColorLight,
              child: const Center(child: Note()),
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
                        selectedTitle = title;
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
                      selectedCategory = category!;
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
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: const Text('All categories'),
        ),
        AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: const Text('All categories'),
        ),
        AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: const Text('All categories'),
          actions: [
            TextButton(
              onPressed: () {
                // save data to db
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

class Note extends StatefulWidget {
  const Note({super.key});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  String title = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        child: TextButton(
            onPressed: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NoteInfoScreen()))
                },
            child: Text(title)),
      ),
    );
  }
}

class NoteInfoScreen extends StatefulWidget {
  const NoteInfoScreen({super.key});

  @override
  State<NoteInfoScreen> createState() => _NoteInfoScreenState();
}

class _NoteInfoScreenState extends State<NoteInfoScreen> {
  String noteTitle = 'Test Note 1';
  String noteContent = 'interensting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('$noteTitle' '\n' 'category: hardcoded'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(noteContent),
      ),
    );
  }
}

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text('Create New Note'),
      ),
      body: const Column(
        children: [
          Text('data'),
          Text('data'),
          Text('text'),
        ],
      ),
    );
  }
}

class NoteDB {
  final int id;
  final String title;
  final String category;
  final String content;
  final DateTime dateModified;
  final String timeNotification; // provisional
  final String locationNotification; // provisional
  final String weatherNotification; // provisional

  NoteDB(
      {required this.id,
      required this.title,
      required this.category,
      required this.content,
      required this.dateModified,
      required this.timeNotification,
      required this.locationNotification,
      required this.weatherNotification});
}
