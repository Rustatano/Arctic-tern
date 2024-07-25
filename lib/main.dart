import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
  Future<File> localData = _localData;
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      drawer: const Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Text('category 1'),
            Text('category 2'),
            Text('category 3')
          ],
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
        const Placeholder(),
      ][currentPageIndex],
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: const Text('All categories'),
      ),
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
  String noteTitle = 'Test Note 1';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: 350,
        child: TextButton(
            onPressed: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const NoteInfoScreen()))
                },
            child: Text(noteTitle)),
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

Future<File> get _localData async {
  final path = await getApplicationDocumentsDirectory();
  return File('$path/counter.txt');
}

Future<File> writeCounter(int counter) async {
  final file = await _localData;

  // Write the file
  return file.writeAsString('$counter');
}

Future<int> readCounter() async {
  try {
    final file = await _localData;

    // Read the file
    final contents = await file.readAsString();

    return int.parse(contents);
  } catch (e) {
    // If encountering an error, return 0
    return 0;
  }
}
