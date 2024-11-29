import 'package:flutter/material.dart';

import 'package:arctic_tern/constants.dart';
import 'package:arctic_tern/db_objects/note.dart';
import 'package:arctic_tern/screens/edit_screen.dart';

class NoteInfoScreen extends StatefulWidget {
  final Note note;

  const NoteInfoScreen({super.key, required this.note});

  @override
  State<NoteInfoScreen> createState() => _NoteInfoScreenState();
}

class _NoteInfoScreenState extends State<NoteInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(Icons.access_time),
                  ),
                  Text(widget.note.from),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(Icons.access_time),
                  ),
                  Text(widget.note.to),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(Icons.pin_drop),
                  ),
                  Flexible(child: Text(widget.note.location)),
                ],
              ),
            ),
            /*
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(Icons.refresh),
                  ),
                  Text(widget.note.repeat),
                ],
              ),
            ),
            */
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  Text(widget.note.content),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
        title: Text(
          widget.note.title,
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScreen(
                    note: widget.note,
                  ),
                ),
              );
            },
            child: Text(
              'Edit',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
