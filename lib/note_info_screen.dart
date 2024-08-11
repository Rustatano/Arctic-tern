import 'package:flutter/material.dart';
import 'package:weather_location_time/db_objects/note.dart';
import 'package:weather_location_time/edit_screen.dart';

class NoteInfoScreen extends StatefulWidget {
  final Note note;
  final Function refreshNotesCallback;

  const NoteInfoScreen(
      {super.key, required this.note, required this.refreshNotesCallback});

  @override
  State<NoteInfoScreen> createState() => _NoteInfoScreenState();
}

class _NoteInfoScreenState extends State<NoteInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(widget.note.title),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScreen(
                      note: widget.note,
                      refreshNotesCallback: widget.refreshNotesCallback),
                ),
              );
            },
            child: Text(
              'Edit',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(widget.note.content),
          ],
        ),
      ),
    );
  }
}
