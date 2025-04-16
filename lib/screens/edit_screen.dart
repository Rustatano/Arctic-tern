import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

import 'package:arctic_tern/db_objects/category.dart';
import 'package:arctic_tern/screens/category_manager_screen.dart';
import 'package:arctic_tern/constants.dart';
import 'package:arctic_tern/db_objects/note.dart';
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
  late Note prevNote;
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
    contentTextFieldController =
        TextEditingController(text: widget.note.content);
    prevNote = widget.note;
    currentCategory = widget.note.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(padding),
          child: ListView(
            children: [
              TextField(
                style: TextStyle(
                  color: AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                ),
                controller: titleTextFieldController,
                maxLines: null,
                onChanged: (String title) {
                  setState(() {
                    editedNote.title = title;
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter a note title',
                  hintStyle: TextStyle(
                    color:
                        AdaptiveTheme.of(context).theme.colorScheme.surfaceDim,
                  ),
                ),
                cursorColor:
                    AdaptiveTheme.of(context).theme.colorScheme.onSurface,
              ),
              Divider(
                color: AdaptiveTheme.of(context).theme.colorScheme.onSurface,
              ),
              // Category selection, new note
              DropdownButton(
                dropdownColor:
                    AdaptiveTheme.of(context).theme.colorScheme.surface,
                underline: Divider(
                  height: 0,
                  color: AdaptiveTheme.of(context).theme.colorScheme.surface,
                ),
                iconEnabledColor:
                    AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                value: currentCategory,
                onChanged: (String? category) async {
                  if (category == null) return;
                  if (category == 'Manage') {
                    setState(() {
                      currentCategory = 'All Categories';
                    });
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryManagerScreen(),
                      ),
                    );
                    await getDBCategories();
                  } else {
                    setState(() {
                      currentCategory = category;
                    });
                  }
                  editedNote.category = currentCategory;
                },
                items: List.generate(categories.length + 2, (i) {
                  if (i == categories.length) {
                    return DropdownMenuItem(
                      value: 'All Categories',
                      child: Row(
                        children: [
                          Icon(
                            Icons.all_inbox_rounded,
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .onSurface,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: halfPadding),
                            child: Text(
                              'All Categories',
                              style: TextStyle(
                                color: AdaptiveTheme.of(context)
                                    .theme
                                    .colorScheme
                                    .onSurface,
                              ),
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
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .onSurface,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: halfPadding),
                            child: Text(
                              'Manage',
                              style: TextStyle(
                                color: AdaptiveTheme.of(context)
                                    .theme
                                    .colorScheme
                                    .onSurface,
                              ),
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
                            categories[i].r,
                            categories[i].g,
                            categories[i].b,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: halfPadding),
                          child: Text(
                            categories[i].category,
                            style: TextStyle(
                              color: AdaptiveTheme.of(context)
                                  .theme
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).reversed.toList(),
              ),
              Divider(
                  color: AdaptiveTheme.of(context).theme.colorScheme.onSurface),
              // time from
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                      AdaptiveTheme.of(context).theme.colorScheme.onSurface),
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
                    backgroundColor:
                        AdaptiveTheme.of(context).theme.colorScheme.surface,
                    builder: (context) => Center(
                      child: DateTimePickerWidget(
                        initDateTime: (editedNote.from == 0)
                            ? getCorrectedDateTime()
                            : DateTime.fromMillisecondsSinceEpoch(
                                editedNote.from),
                        dateFormat: 'yyyy:MM:dd:HH:mm',
                        minuteDivider: 5,
                        onConfirm: (from, _) {
                          if (editedNote.to != 0) {
                            var to = DateTime.fromMillisecondsSinceEpoch(
                                editedNote.to);
                            if (editedNote.from != 0 &&
                                DateTime.fromMillisecondsSinceEpoch(
                                        editedNote.from)
                                    .isAtSameMomentAs(to) &&
                                DateTime.fromMillisecondsSinceEpoch(
                                        editedNote.from)
                                    .isBefore(from)) {
                              setState(() {
                                editedNote.to = from.millisecondsSinceEpoch;
                              });
                            } else if (from.isAfter(to)) {
                              setState(
                                () {
                                  editedNote.to = from
                                      .add(
                                        Duration(
                                          seconds: ((from.millisecondsSinceEpoch -
                                                      to.millisecondsSinceEpoch) /
                                                  1000)
                                              .floor(),
                                        ),
                                      )
                                      .millisecondsSinceEpoch;
                                },
                              );
                            }
                          }
                          setState(() {
                            editedNote.from = from.millisecondsSinceEpoch;
                          });
                        },
                        onCancel: () {
                          setState(() {
                            editedNote.from = 0;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Text(
                    'From: ${(editedNote.from == 0) ? '' : DateTime.fromMillisecondsSinceEpoch(editedNote.from).toString().substring(0, 16)}'),
              ),
              // time to
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                      AdaptiveTheme.of(context).theme.colorScheme.onSurface),
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
                    backgroundColor:
                        AdaptiveTheme.of(context).theme.colorScheme.surface,
                    builder: (context) => Center(
                      child: DateTimePickerWidget(
                        initDateTime: (editedNote.to == 0)
                            ? getCorrectedDateTime()
                            : DateTime.fromMillisecondsSinceEpoch(
                                editedNote.to),
                        dateFormat: 'yyyy:MM:dd:HH:mm',
                        minuteDivider: 5,
                        onConfirm: (to, _) {
                          if (editedNote.from != 0) {
                            var from = DateTime.fromMillisecondsSinceEpoch(
                                editedNote.from);
                            if (editedNote.to != 0 &&
                                DateTime.fromMillisecondsSinceEpoch(
                                        editedNote.to)
                                    .isAtSameMomentAs(from) &&
                                DateTime.fromMillisecondsSinceEpoch(
                                        editedNote.to)
                                    .isAfter(to)) {
                              setState(() {
                                editedNote.from = to.millisecondsSinceEpoch;
                              });
                            } else if (to.isBefore(from)) {
                              setState(
                                () {
                                  editedNote.from = to
                                      .add(
                                        Duration(
                                          seconds: ((to.millisecondsSinceEpoch -
                                                      from.millisecondsSinceEpoch) /
                                                  1000)
                                              .floor(),
                                        ),
                                      )
                                      .millisecondsSinceEpoch;
                                },
                              );
                            }
                          }
                          setState(() {
                            editedNote.to = to.millisecondsSinceEpoch;
                          });
                        },
                        onCancel: () {
                          setState(() {
                            editedNote.to = 0;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Text(
                    'To: ${(editedNote.to == 0) ? '' : DateTime.fromMillisecondsSinceEpoch(editedNote.to).toString().substring(0, 16)}'),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                      AdaptiveTheme.of(context).theme.colorScheme.onSurface),
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
                    backgroundColor:
                        AdaptiveTheme.of(context).theme.colorScheme.surface,
                    builder: (context) => Center(
                      child: CupertinoPicker(
                        itemExtent: 20.0,
                        onSelectedItemChanged: (repeat) {
                          setState(() {
                            switch (repeat) {
                              case 0:
                                editedNote.repeat = '';
                              case 1:
                                editedNote.repeat = 'Daily';
                              case 2:
                                editedNote.repeat = 'Weekly';
                              case 3:
                                editedNote.repeat = 'Monthly';
                              case 4:
                                editedNote.repeat = 'Yearly';
                            }
                          });
                        },
                        children: [
                          const Text('None'),
                          const Text('Daily'),
                          const Text('Weekly'),
                          const Text('Monthly'),
                          const Text('Yearly'),
                        ],
                      ),
                    ),
                  );
                },
                child: Text('Repeat: ${editedNote.repeat}'),
              ),
              // location
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                      AdaptiveTheme.of(context).theme.colorScheme.onSurface),
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
                      if (editedNote.from == 0) {
                        editedNote.from =
                            getCorrectedDateTime().millisecondsSinceEpoch;
                      }
                      editedNote.location = jsonEncode(location);
                    });
                  }
                },
                child: Text('Location: ${editedNote.location}'),
              ),
              Divider(
                color: AdaptiveTheme.of(context).theme.colorScheme.onSurface,
              ),
              TextField(
                style: TextStyle(
                  color: AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                ),
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
                  hintStyle: TextStyle(
                    color:
                        AdaptiveTheme.of(context).theme.colorScheme.surfaceDim,
                  ),
                ),
                cursorColor:
                    AdaptiveTheme.of(context).theme.colorScheme.onSurface,
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
              color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
              size: 25,
            ),
          ),
          backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
          title: Text(
            'Edit Note',
            style: TextStyle(
                color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                editedNote.trimProperties();
                if (editedNote.title.isEmpty) {
                  editedNote.title = DateTime.now().toString().substring(5, 19);
                }
                if (editedNote.from == 0 &&
                    editedNote.to == 0 &&
                    editedNote.location == '') {
                  editedNote.active = 0;
                } else {
                  editedNote.active = 1;
                }

                if (editedNote.from != 0 && editedNote.to != 0 ||
                    editedNote.from == 0 && editedNote.to == 0) {
                  editedNote.dateModified =
                      DateTime.now().millisecondsSinceEpoch;
                  await prevNote.update(editedNote);
                  if (context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                } else if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Note'),
                      content: Text('You must select time notification'),
                    ),
                  );
                }
              },
              child: Icon(
                Icons.check,
                color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
                size: 25,
              ),
            ),
          ],
        ),
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
