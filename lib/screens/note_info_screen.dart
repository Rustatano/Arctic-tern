import 'package:adaptive_theme/adaptive_theme.dart';
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
      backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(
                      Icons.access_time,
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Text(
                      'From: ',
                      style: TextStyle(
                        color: AdaptiveTheme.of(context)
                            .theme
                            .colorScheme
                            .onSurface,
                      ),
                    ),
                  ),
                  Text(
                    widget.note.from == 0 ? '' : DateTime.fromMillisecondsSinceEpoch(widget.note.from).toString().substring(0, 16),
                    style: TextStyle(
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(
                      Icons.access_time,
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Text(
                      'To: ',
                      style: TextStyle(
                        color: AdaptiveTheme.of(context)
                            .theme
                            .colorScheme
                            .onSurface,
                      ),
                    ),
                  ),
                  Text(
                    widget.note.to == 0 ? '' : DateTime.fromMillisecondsSinceEpoch(widget.note.to).toString().substring(0, 16),
                    style: TextStyle(
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: halfPadding),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Icon(
                      Icons.pin_drop,
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: halfPadding),
                    child: Text(
                      'Location: ',
                      style: TextStyle(
                        color: AdaptiveTheme.of(context)
                            .theme
                            .colorScheme
                            .onSurface,
                      ),
                    ),
                  ),
                  Flexible(
                      child: Text(
                    widget.note.location,
                    style: TextStyle(
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                    ),
                  )),
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
            Divider(
                color: AdaptiveTheme.of(context).theme.colorScheme.onSurface),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    DateTime.fromMillisecondsSinceEpoch(widget.note.dateModified).toString().substring(0, 16),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AdaptiveTheme.of(context)
                          .theme
                          .colorScheme
                          .surfaceDim,
                    ),
                  ),
                  Text(
                    widget.note.content,
                    style: TextStyle(
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
        backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
        title: Text(
          widget.note.title,
          style: TextStyle(
              color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Navigator.push(
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
              style: TextStyle(
                  color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
