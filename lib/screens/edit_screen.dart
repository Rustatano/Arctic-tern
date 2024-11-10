import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/constants.dart';
import 'package:arctic_tern/db_objects/note.dart';
import 'package:arctic_tern/notifications/notification.dart';
import 'package:arctic_tern/screens/location_selection_screen.dart';

class EditScreen extends StatefulWidget {
  final Note note;

  const EditScreen({
    super.key,
    required this.note,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Note editedNote;
  late TextEditingController titleTextController;
  late TextEditingController contentTextController;
  late String prevTitle;

  @override
  void initState() {
    super.initState();
    editedNote = Note.fromMap(widget.note.toMap()); // copy note
    titleTextController = TextEditingController(text: widget.note.title);
    contentTextController = TextEditingController(text: widget.note.content);
    prevTitle = widget.note.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: ListView(
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - doublePadding,
                  child: TextField(
                    maxLines: null,
                    controller: titleTextController,
                    onChanged: (String title) {
                      setState(() {
                        editedNote.title = title;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter a note title',
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                DropdownMenu(
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                  ),
                  initialSelection: editedNote.category,
                  onSelected: (String? category) {
                    setState(() {
                      editedNote.category = category!;
                    });
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(
                      value: 'Category',
                      label: 'Category',
                      leadingIcon: Icon(
                        Icons.square,
                        color: Colors.white,
                      ),
                    ), // make sure user cant create category named 'Category' & 'Create', it would cause collision
                    DropdownMenuEntry(
                      value: 'School',
                      label: 'School',
                      leadingIcon: Icon(
                        Icons.square,
                        color: Colors.blue,
                      ),
                    ),
                    DropdownMenuEntry(
                      value: 'Work',
                      label: 'Work',
                      leadingIcon: Icon(
                        Icons.square,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                // time notification
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final date = await showDateTimePicker(
                              context: context,
                              initialDate: editedNote.timeNotification);
                          List<Padding> timeScale = const [
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text('months'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text('days'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text('hours'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text('minutes'),
                            ),
                          ];
                          if (date == null) {
                            setState(() {
                              editedNote.timeNotification = '';
                              editedNote.notificationPeriod = '';
                            });
                            return;
                          }
                          List<Widget> timeCount = [];
                          for (var i = 1; i < 32; i++) {
                            timeCount.add(
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(i.toString()),
                              ),
                            );
                          }
                          int selectedTimeScale = 0;
                          int selectedTimeCount = 1;
                          if (!context.mounted) {
                            return;
                          }
                          await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: SizedBox(
                                width: 300,
                                height: 200,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: padding, bottom: padding),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 30,
                                              onSelectedItemChanged: (val) {
                                                selectedTimeScale = val;
                                              },
                                              children: timeScale,
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 30,
                                              onSelectedItemChanged: (val) {
                                                selectedTimeCount = val;
                                              },
                                              children: timeCount,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            selectedTimeScale = -1;
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                          // approximate, do this exact
                          setState(() {
                            selectedTimeCount++;
                            switch (selectedTimeScale) {
                              case 0:
                                editedNote.notificationPeriod =
                                    (2629800 * selectedTimeCount).toString();
                                break;
                              case 1:
                                editedNote.notificationPeriod =
                                    (86400 * selectedTimeCount).toString();
                                break;
                              case 2:
                                editedNote.notificationPeriod =
                                    (3600 * selectedTimeCount).toString();
                                break;
                              case 3:
                                editedNote.notificationPeriod =
                                    (60 * selectedTimeCount).toString();
                                break;
                              default:
                                editedNote.notificationPeriod = '';
                                break;
                            }
                          });
                          setState(() {
                            editedNote.timeNotification =
                                date.toString().substring(0, 16);
                          });
                        },
                        icon: Icon(
                          Icons.access_time,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${editedNote.timeNotification} ${editedNote.notificationPeriod}',
                        style: const TextStyle(fontSize: smallFontSize),
                      ),
                    ],
                  ),
                ),
                // location notification
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LocationSelectionScreen(),
                            ),
                          );
                          setState(() {
                            editedNote.locationNotification =
                                (result != null) ? jsonEncode(result) : '';
                          });
                        },
                        icon: Icon(
                          Icons.pin_drop,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(editedNote.locationNotification),
                    ],
                  ),
                ),
                // weather notification
                /*Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.cloud),
                      ),
                      Text(editedNote.weatherNotification),
                    ],
                  ),
                ),*/
                // repeat
              ],
            ),
            const Divider(),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - doublePadding,
                  child: TextField(
                    controller: contentTextController,
                    maxLines: null,
                    onChanged: (String content) {
                      setState(() {
                        editedNote.content = content;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Start typing here',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
        title: Text(
          'Edit',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              editedNote.trimProperties();
              if (editedNote.title.isNotEmpty) {
                if (!await editedNote.exists() ||
                    prevTitle == editedNote.title) {
                  if (editedNote.timeNotification != '' ||
                      editedNote.locationNotification == ''/* &&
                          editedNote.weatherNotification == ''*/) {
                    Duration? frequency;
                    int delay = 0;
                    if (editedNote.notificationPeriod != '') {
                      frequency = Duration(
                          seconds: int.parse(editedNote.notificationPeriod));
                    }
                    if (editedNote.timeNotification != '') {
                      delay = ((DateTime.parse(editedNote.timeNotification)
                                      .millisecondsSinceEpoch -
                                  DateTime.now().millisecondsSinceEpoch) /
                              1000)
                          .round();
                      Workmanager().registerPeriodicTask(
                        editedNote.title,
                        editedNote.title,
                        initialDelay: Duration(seconds: delay),
                        inputData: editedNote.toMap(),
                        frequency: frequency,
                      );
                    }
                    await editedNote.insert();
                    setState(() {
                      editedNote = Note.toDefault();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  } else if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Note'),
                        content: Text('You must select time notification'),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('Error'),
                        content: Text(
                            'Note title already exists. Notes cannot have the same titles'),
                      ),
                    );
                  }
                }
              } else {
                editedNote.title = '(no title)';
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
