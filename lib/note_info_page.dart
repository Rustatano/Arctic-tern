import 'package:flutter/material.dart';
import 'package:weather_location_time/db_objects/note.dart';

class NoteInfoPage extends StatefulWidget {
  final NoteDB note;
  const NoteInfoPage({super.key, required this.note});

  @override
  State<NoteInfoPage> createState() => _NoteInfoPageState();
}

class _NoteInfoPageState extends State<NoteInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        actions: [
          TextButton(
            onPressed: () {},
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
