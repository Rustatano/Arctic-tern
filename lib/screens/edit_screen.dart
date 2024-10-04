import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_note/constants.dart';
import 'package:weather_note/db_objects/note.dart';
import 'package:weather_note/notifications/notification.dart';
import 'package:weather_note/screens/location_selection_screen.dart';
import 'package:workmanager/workmanager.dart';

class EditScreen extends StatefulWidget {
  final Note note;
  final Function refreshNotesCallback;

  const EditScreen(
      {super.key, required this.note, required this.refreshNotesCallback});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Note editedNote;
  late TextEditingController titleTextController;
  late TextEditingController contentTextController;
  late String prevTitle;
  bool isTimeNotificationSelected = false;

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
                          setState(() {
                            editedNote.timeNotification = '';
                          });
                          if (date != null) {
                            setState(() {
                              editedNote.timeNotification =
                                  date.toString().substring(0, 16);
                              isTimeNotificationSelected = true;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.access_time,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        editedNote.timeNotification,
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
                        onPressed: (isTimeNotificationSelected)
                            ? () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LocationSelectionScreen(),
                                  ),
                                );
                                setState(() {
                                  editedNote.locationNotification =
                                      (result != null)
                                          ? jsonEncode(result)
                                          : '';
                                });
                              }
                            : () => {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const AlertDialog(
                                      title: Text('Note'),
                                      content: Text(
                                        'You must select time notification first',
                                      ),
                                    ),
                                  )
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
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.cloud),
                      ),
                      Text(editedNote.weatherNotification),
                    ],
                  ),
                ),
                // repeat
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () async {
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
                          List<Widget> timeCount = [];
                          for (var i = 1; i < 24; i++) {
                            timeCount.add(Text(i.toString()));
                          }
                          int selectedTimeScale = 0;
                          int selectedTimeCount = 1;
                          await showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: SizedBox(
                                width: 300, // make this adaptable
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
                                              // inspiritaion in notifications on my phone
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
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Save'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            selectedTimeScale = 10;
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        )
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
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(editedNote.notificationPeriod),
                    ],
                  ),
                )
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
                if (!await Note.exists(editedNote.title) ||
                    editedNote.title == prevTitle) {
                  if (editedNote.timeNotification.isNotEmpty) {
                    Workmanager().cancelByUniqueName(prevTitle);
                    int delay = ((DateTime.parse(editedNote.timeNotification)
                                    .millisecondsSinceEpoch -
                                DateTime.now().millisecondsSinceEpoch) /
                            1000)
                        .round();
                    Workmanager().registerOneOffTask(
                      editedNote.title,
                      editedNote.title,
                      initialDelay: Duration(seconds: delay),
                      inputData: editedNote.toMap(),
                    );
                  }

                  await Note.removeNote(prevTitle);
                  await editedNote.insert();
                  if (context.mounted) {
                    widget.refreshNotesCallback();
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
                showDialog(
                  context: context,
                  builder: (context) => const AlertDialog(
                    title: Text('Error'),
                    content: Text('Note title is required'),
                  ),
                );
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
