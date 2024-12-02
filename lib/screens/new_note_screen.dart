import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

import 'package:arctic_tern/db_objects/category.dart';
import 'package:arctic_tern/screens/category_manager_screen.dart';
import 'package:arctic_tern/constants.dart';
import 'package:arctic_tern/db_objects/note.dart';
import 'package:arctic_tern/screens/location_selection_screen.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({
    super.key,
  });

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  Note newNote = Note.toDefault();
  List<DBCategory> categories = [];
  TextEditingController contentTextFieldController = TextEditingController();
  TextEditingController titleTextFieldController = TextEditingController();
  String currentCategory = 'No Category';

  Future<void> getDBCategories() async {
    final c = await DBCategory.getDBCategories();
    setState(() {
      categories = c;
    });
  }

  @override
  void initState() {
    getDBCategories();
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
            TextField(
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
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            // Category selection, new note
            DropdownButton(
              underline: Divider(
                height: 0,
                color: colorScheme.surface,
              ),
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
                  });
                }
                await getDBCategories();
                newNote.category = currentCategory;
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
                        ),
                      ),
                    ],
                  ),
                );
              }).reversed.toList(),
            ),
            const Divider(color: Colors.black),
            // time from
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints.tight(
                    Size(
                      MediaQuery.sizeOf(context).width,
                      MediaQuery.sizeOf(context).height * 0.33,
                    ),
                  ),
                  backgroundColor: colorScheme.surface,
                  builder: (context) => Center(
                    child: DateTimePickerWidget(
                      initDateTime: (newNote.from == '')
                          ? getCorrectedDateTime()
                          : DateTime.parse(newNote.from),
                      dateFormat: 'yyyy:MM:dd:HH:mm',
                      minuteDivider: 5,
                      onConfirm: (from, _) {
                        if (newNote.to.isNotEmpty) {
                          var to = DateTime.parse(newNote.to);
                          if (newNote.from.isNotEmpty && DateTime.parse(newNote.from)
                              .isAtSameMomentAs(to) && DateTime.parse(newNote.from).isBefore(from)) {
                            setState(() {
                              newNote.to = from.toString().substring(0, 16);
                            });
                          } else if (from.isAfter(to)) {
                            setState(() {
                              newNote.to = from
                                  .add(Duration(
                                      seconds: ((from.millisecondsSinceEpoch -
                                                  to.millisecondsSinceEpoch) /
                                              1000)
                                          .floor()))
                                  .toString()
                                  .substring(0, 16);
                            });
                          }
                        }
                        setState(() {
                          newNote.from = from.toString().substring(0, 16);
                        });
                      },
                      onCancel: () {
                        setState(() {
                          newNote.from = '';
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('From: ${newNote.from}'),
            ),
            // time to
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints.tight(
                    Size(
                      MediaQuery.sizeOf(context).width,
                      MediaQuery.sizeOf(context).height * 0.33,
                    ),
                  ),
                  backgroundColor: colorScheme.surface,
                  builder: (context) => Center(
                    child: DateTimePickerWidget(
                      initDateTime: (newNote.to == '')
                          ? getCorrectedDateTime()
                          : DateTime.parse(newNote.to),
                      dateFormat: 'yyyy:MM:dd:HH:mm',
                      minuteDivider: 5,
                      onConfirm: (to, _) {
                        if (newNote.from.isNotEmpty) {
                          var from = DateTime.parse(newNote.from);
                          if (newNote.to.isNotEmpty && DateTime.parse(newNote.to)
                              .isAtSameMomentAs(from) && DateTime.parse(newNote.to).isAfter(to)) {
                            setState(() {
                              newNote.from = to.toString().substring(0, 16);
                            });
                          } else if (to.isBefore(from)) {
                            setState(() {
                              newNote.from = to
                                  .add(Duration(
                                      seconds: ((to.millisecondsSinceEpoch -
                                                  from.millisecondsSinceEpoch) /
                                              1000)
                                          .floor()))
                                  .toString()
                                  .substring(0, 16);
                            });
                          }
                        }
                        setState(() {
                          newNote.to = to.toString().substring(0, 16);
                        });
                      },
                      onCancel: () {
                        setState(() {
                          newNote.to = '';
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('To: ${newNote.to}'),
            ),
            /*
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () async {},
              child: Text('Repeat every: ${newNote.repeat}'),
            ),
            */
            // location
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () async {
                Map<String, double>? location = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationSelectionScreen(),
                  ),
                );
                if (location != null) {
                  setState(() {
                    if (newNote.from == '') {
                      newNote.from =
                          getCorrectedDateTime().toString().substring(0, 16);
                    }
                    newNote.location = jsonEncode(location);
                  });
                }
              },
              child: Text('Location: ${newNote.location}'),
            ),
            const Divider(
              color: Colors.black,
            ),
            TextField(
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
              ),
              cursorColor: colorScheme.onSurface,
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
                if (newNote.from == '' &&
                    newNote.to == '' &&
                    newNote.location == '') {
                  newNote.active = 'false';
                } else {
                  newNote.active = 'true';
                }
                if (newNote.from != '' && newNote.to != '' ||
                    newNote.from == '' && newNote.to == '') {
                  await newNote.insert();
                  if (context.mounted) Navigator.pop(context);
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
                      content: Text('Note with the same title already exists.'),
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

  static DateTime getCorrectedDateTime() {
    int seconds = DateTime.now().second;
    int minutes = DateTime.now().minute;
    int delay = 60 * (((minutes / 5).floor() + 1) * 5 - minutes) - seconds;
    return DateTime.now().add(Duration(seconds: delay));
  }
}
