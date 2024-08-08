import 'package:flutter/material.dart';
import 'package:weather_location_time/db_objects/note.dart';
import 'package:weather_location_time/edit_screen.dart';

class NoteInfoScreen extends StatefulWidget {
  final Note note;
  final Function refreshNotesCallback;

  const NoteInfoScreen({super.key, required this.note, required this.refreshNotesCallback});

  @override
  State<NoteInfoScreen> createState() => _NoteInfoScreenState();
}

class _NoteInfoScreenState extends State<NoteInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScreen(note: widget.note, refreshNotesCallback: widget.refreshNotesCallback),
                ),
              );
            },
            child: const Text(
              'Edit',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(widget.note.content),
      ),
    );
  }
}
