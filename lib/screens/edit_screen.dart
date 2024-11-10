import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/db_objects/categories.dart';
import 'package:arctic_tern/screens/category_manager_screen.dart';
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
  late TextEditingController titleTextFieldController;
  late TextEditingController contentTextFieldController;
  late String prevTitle;
  late String currentCategory;
  List<DBCategory> categories = [];
  
  Future<void> getDBCategories() async {
    final c = await DBCategory.getDBCategories();
    setState(() {
      categories = c;
    });
  }

  @override
  void initState() {
    getDBCategories();
    editedNote = Note.fromMap(widget.note.toMap()); // copy note
    titleTextFieldController = TextEditingController(text: widget.note.title);
    contentTextFieldController = TextEditingController(text: widget.note.content);
    prevTitle = widget.note.title;
    currentCategory = widget.note.category;
    super.initState();
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
                    controller: titleTextFieldController,
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
                // Category selection, edit note
                DropdownButton(
                  value: currentCategory,
                  onChanged: (String? category) async {
                    if (category == null) return;
                    if (category == 'Manage') {
                      setState(() {
                        currentCategory = 'No Category';
                      });
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryManagerScreen(),
                        ),
                      );
                    } else {
                      setState(() {
                        currentCategory = category;
                        editedNote.category = currentCategory;
                      });
                    }
                    await getDBCategories();
                  },
                  items: List.generate(categories.length + 2, (i) {
                    if (i == categories.length) {
                      return DropdownMenuItem(
                        value: 'No Category',
                        child: Row(
                          children: [
                            Icon(
                              Icons.all_inbox_rounded,
                              color: colorScheme.onSurface,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: halfPadding),
                              child: Text(
                                'No Category',
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (i == categories.length + 1) {
                      return DropdownMenuItem(
                        value: 'Manage',
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu,
                              color: colorScheme.onSurface,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: halfPadding),
                              child: Text(
                                'Manage',
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return DropdownMenuItem(
                      value: categories[i].category,
                      child: Row(
                        children: [
                          Icon(
                            Icons.square_rounded,
                            color: Color.fromARGB(
                              255,
                              int.parse(categories[i].r),
                              int.parse(categories[i].g),
                              int.parse(categories[i].b),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: halfPadding),
                            child: Text(
                              categories[i].category,
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).reversed.toList(),
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
                        initialDate: editedNote.timeNotification,
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
                          editedNote.timeNotification =
                              date.toString().substring(0, 16);
                          if (repeatCount == '0' ||
                              repeatCount == null ||
                              repeatType == '' ||
                              repeatType == null) {
                            editedNote.notificationPeriod = '';
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
                            editedNote.notificationPeriod = repeat.toString();
                          }
                        } else {
                          editedNote.timeNotification = '';
                        }
                      });
                    },
                    icon: Badge(
                      isLabelVisible: editedNote.timeNotification != '',
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
                        editedNote.locationNotification =
                            (result != null) ? jsonEncode(result) : '';
                      });
                    },
                    icon: Badge(
                      isLabelVisible: editedNote.locationNotification != '',
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
                /*Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: Badge(
                      isLabelVisible: editedNote.weatherNotification != '',
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
                ),*/
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
                        editedNote.content = content;
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
                          editedNote.locationNotification ==
                              '' /* &&
                          editedNote.weatherNotification == ''*/
                      ) {
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
                    await Note.removeNote(prevTitle);
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
