import 'dart:convert';

import 'package:arctic_tern/notifications/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/constants.dart';
import 'package:arctic_tern/db_objects/note.dart';
import 'package:arctic_tern/screens/location_selection_screen.dart';

class NewNoteScreen extends StatefulWidget {
  final Function refreshNotesCallback;
  const NewNoteScreen({
    super.key,
    required this.refreshNotesCallback,
  });

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  Note newNote = Note.toDefault();
  TextEditingController contentTextFieldController = TextEditingController();
  TextEditingController titleTextFieldController = TextEditingController();

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
                    controller: titleTextFieldController,
                    maxLines: null,
                    onChanged: (String title) {
                      setState(() {
                        newNote.title = title;
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter a note title',
                      hintStyle: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                // Category selection, new note
                DropdownMenu(
                  trailingIcon: Icon(
                    Icons.arrow_drop_down,
                    color: colorScheme.onSurface,
                  ),
                  selectedTrailingIcon: Icon(
                    Icons.arrow_drop_up,
                    color: colorScheme.onPrimary,
                  ),
                  menuStyle: MenuStyle(
                      backgroundColor:
                          WidgetStateProperty.all(colorScheme.primary)),
                  inputDecorationTheme: InputDecorationTheme(
                    border: InputBorder.none,
                  ),
                  initialSelection: 'Category',
                  onSelected: (String? category) {
                    setState(() {
                      newNote.category = category!;
                    });
                  },
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStatePropertyAll(colorScheme.onPrimary),
                      ),
                      value: 'Category',
                      label: 'Category',
                      leadingIcon: Icon(
                        Icons.square_rounded,
                        color: Colors.white,
                      ),
                    ), // make sure user cant create category named 'Category' & 'Create', it would cause collision
                    DropdownMenuEntry(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStatePropertyAll(colorScheme.onPrimary),
                      ),
                      value: 'School',
                      label: 'School',
                      leadingIcon: Icon(
                        Icons.square_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    DropdownMenuEntry(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStatePropertyAll(colorScheme.onPrimary),
                      ),
                      value: 'Work',
                      label: 'Work',
                      leadingIcon: Icon(
                        Icons.square_rounded,
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
                  child: IconButton(
                    onPressed: () async {
                      final date = await showDateTimePicker(
                        context: context,
                        initialDate: newNote.timeNotification,
                      );

                      String? repeatType;
                      String? repeatCount;
                      if (date != null) {
                        List<Text> timeCountList = [];
                        List<Text> timeTypeList = [
                          Text('days'),
                          Text('weeks'),
                          Text('months'),
                          Text('years'),
                        ];
                        for (var i = 0; i < 100; i++) {
                          timeCountList.add(Text(i.toString()));
                        }
                        if (!context.mounted) return;

                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: SizedBox(
                              width: 200,
                              height: 400,
                              child: Padding(
                                padding: const EdgeInsets.all(halfPadding),
                                child: Column(
                                  children: [
                                    Text('Select repeat time'),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 40,
                                              onSelectedItemChanged:
                                                  (valIndex) {
                                                repeatCount =
                                                    timeCountList[valIndex]
                                                        .data!;
                                              },
                                              children: timeCountList,
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 40,
                                              onSelectedItemChanged:
                                                  (valIndex) {
                                                repeatType =
                                                    timeTypeList[valIndex]
                                                        .data!;
                                              },
                                              children: timeTypeList,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            repeatCount = '';
                                            repeatType = '';
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      setState(() {
                        if (date != null) {
                          newNote.timeNotification =
                              date.toString().substring(0, 16);
                          if (repeatCount == '0' ||
                              repeatCount == null ||
                              repeatType == '' ||
                              repeatType == null) {
                            newNote.notificationPeriod = '';
                          } else {
                            int repeat = 0;
                            switch (repeatType) {
                              case 'days':
                                repeat = int.parse(repeatCount!) * 60 * 24;
                                break;
                              case 'weeks':
                                repeat = int.parse(repeatCount!) * 60 * 24 * 7;
                                break;
                              case 'months':
                                // not accurate
                                repeat = int.parse(repeatCount!) * 60 * 24 * 30;
                                break;
                              case 'years':
                                // not accurate
                                repeat =
                                    int.parse(repeatCount!) * 60 * 24 * 365;
                                break;
                              default:
                            }
                            newNote.notificationPeriod = repeat.toString();
                          }
                        } else {
                          newNote.timeNotification = '';
                        }
                      });
                    },
                    icon: Badge(
                      isLabelVisible: newNote.timeNotification != '',
                      label: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.access_time,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                // location notification
                Expanded(
                  child: IconButton(
                    disabledColor: colorScheme.primary,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationSelectionScreen(),
                        ),
                      );
                      setState(() {
                        newNote.locationNotification =
                            (result != null) ? jsonEncode(result) : '';
                      });
                    },
                    icon: Badge(
                      isLabelVisible: newNote.locationNotification != '',
                      label: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.pin_drop,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                // weather notification
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: Badge(
                      isLabelVisible: newNote.weatherNotification != '',
                      label: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.cloud,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - doublePadding,
                  child: TextField(
                    controller: contentTextFieldController,
                    maxLines: null,
                    onChanged: (String content) {
                      setState(() {
                        newNote.content = content;
                      });
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Start typing here',
                        hintStyle: TextStyle(color: colorScheme.onSurface)),
                    cursorColor: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        title: Text(
          'New Note',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              newNote.trimProperties();
              if (newNote.title.isEmpty) {
                newNote.title = DateTime.now().toString().substring(5, 19);
              }
              if (!await newNote.exists()) {
                if (newNote.timeNotification != '' ||
                    newNote.locationNotification == '' &&
                        newNote.weatherNotification == '') {
                  Duration? frequency;
                  int delay = 0;
                  if (newNote.timeNotification != '') {
                    delay = ((DateTime.parse(newNote.timeNotification)
                                    .millisecondsSinceEpoch -
                                DateTime.now().millisecondsSinceEpoch) /
                            1000)
                        .round();
                    if (newNote.notificationPeriod != '') {
                      int repeatPeriod = int.parse(newNote.notificationPeriod);
                      frequency = Duration(minutes: repeatPeriod);
                      if (newNote.locationNotification != '') {
                        int count = 1;
                        while (count * repeatPeriod < 15) {
                          count++;
                        }
                        for (var i = 0; i < count; i++) {
                          Workmanager().registerPeriodicTask(
                            newNote.title + i.toString(),
                            newNote.title + i.toString(),
                            initialDelay: Duration(
                                seconds: delay + i * repeatPeriod * 60),
                            frequency: Duration(minutes: count * repeatPeriod),
                            inputData: newNote.toMap(),
                          );
                        }
                      } else {
                        Workmanager().registerPeriodicTask(
                          newNote.title,
                          newNote.title,
                          initialDelay: Duration(seconds: delay),
                          inputData: newNote.toMap(),
                          frequency: frequency,
                        );
                      }
                    } else {
                      Workmanager().registerOneOffTask(
                        newNote.title,
                        newNote.title,
                        initialDelay: Duration(seconds: delay),
                        inputData: newNote.toMap(),
                      );
                    }
                  }
                  await newNote.insert();
                  setState(() {
                    contentTextFieldController.clear();
                    titleTextFieldController.clear();
                    newNote = Note.toDefault();
                    widget.refreshNotesCallback();
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
            },
            child: Icon(
              Icons.check,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
