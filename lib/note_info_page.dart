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
      ),
      body: const Center(
        child: Text('Note Info'),
      ),
    );
  }
}