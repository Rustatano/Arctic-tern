import 'package:flutter/material.dart';
import 'package:weather_note/constants.dart';
import 'package:weather_note/db_objects/note.dart';
import 'package:weather_note/screens/edit_screen.dart';

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
                  Text(widget.note.timeNotification),
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
                  Flexible(child: Text(widget.note.locationNotification)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(Icons.cloud),
                  ),
                  Text(widget.note.weatherNotification),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(Icons.refresh),
                  ),
                  Text(widget.note.notificationPeriod),
                ],
              ),
            ),
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
                    refreshNotesCallback: widget.refreshNotesCallback,
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
