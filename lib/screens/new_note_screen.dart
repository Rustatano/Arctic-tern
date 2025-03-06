import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
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
  String currentCategory = 'All Categories';

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
                maxLines: 1,
                onChanged: (String title) {
                  setState(() {
                    newNote.title = title;
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
                  color: AdaptiveTheme.of(context)
                      .theme
                      .colorScheme
                      .surface, // its surface intentionally
                ),
                iconEnabledColor:
                    AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                value: currentCategory,
                onChanged: (String? category) async {
                  FocusScope.of(context).unfocus();
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
                  newNote.category = currentCategory;
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
                        initDateTime: (newNote.from == 0)
                            ? getCorrectedDateTime()
                            : DateTime.fromMillisecondsSinceEpoch(newNote.from),
                        dateFormat: 'yyyy:MM:dd:HH:mm',
                        minuteDivider: 5,
                        onConfirm: (from, _) {
                          if (newNote.to != 0) {
                            var to =
                                DateTime.fromMillisecondsSinceEpoch(newNote.to);
                            if (newNote.from != 0 &&
                                DateTime.fromMillisecondsSinceEpoch(
                                        newNote.from)
                                    .isAtSameMomentAs(to) &&
                                DateTime.fromMillisecondsSinceEpoch(
                                        newNote.from)
                                    .isBefore(from)) {
                              setState(() {
                                newNote.to = from.millisecondsSinceEpoch;
                              });
                            } else if (from.isAfter(to)) {
                              setState(
                                () {
                                  newNote.to = from
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
                            newNote.from = from.millisecondsSinceEpoch;
                          });
                        },
                        onCancel: () {
                          setState(() {
                            newNote.from = 0;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Text(
                    'From: ${(newNote.from == 0) ? '' : DateTime.fromMillisecondsSinceEpoch(newNote.from).toString().substring(0, 16)}'),
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
                        initDateTime: (newNote.to == 0)
                            ? getCorrectedDateTime()
                            : DateTime.fromMillisecondsSinceEpoch(newNote.to),
                        dateFormat: 'yyyy:MM:dd:HH:mm',
                        minuteDivider: 5,
                        onConfirm: (to, _) {
                          if (newNote.from != 0) {
                            var from = DateTime.fromMillisecondsSinceEpoch(
                                newNote.from);
                            if (newNote.to != 0 &&
                                DateTime.fromMillisecondsSinceEpoch(newNote.to)
                                    .isAtSameMomentAs(from) &&
                                DateTime.fromMillisecondsSinceEpoch(newNote.to)
                                    .isAfter(to)) {
                              setState(() {
                                newNote.from = to.millisecondsSinceEpoch;
                              });
                            } else if (to.isBefore(from)) {
                              setState(() {
                                newNote.from = to
                                    .add(
                                      Duration(
                                        seconds: ((to.millisecondsSinceEpoch -
                                                    from.millisecondsSinceEpoch) /
                                                1000)
                                            .floor(),
                                      ),
                                    )
                                    .millisecondsSinceEpoch;
                              });
                            }
                          }
                          setState(() {
                            newNote.to = to.millisecondsSinceEpoch;
                          });
                        },
                        onCancel: () {
                          setState(() {
                            newNote.to = 0;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Text(
                    'To: ${(newNote.to == 0) ? '' : DateTime.fromMillisecondsSinceEpoch(newNote.to).toString().substring(0, 16)}'),
              ),
              /*
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(AdaptiveTheme.of(context).theme.colorScheme.onSurface),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () async {},
                child: Text('Repeat every: ${newNote.repeat}'),
              ),
              */
              // location
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                      AdaptiveTheme.of(context).theme.colorScheme.onSurface),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  Map<String, dynamic>? location = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationSelectionScreen(),
                    ),
                  );
                  if (location != null) {
                    setState(() {
                      if (newNote.from == 0) {
                        newNote.from =
                            getCorrectedDateTime().millisecondsSinceEpoch;
                      }
                      if (newNote.to == 0) {
                        newNote.to =
                            getCorrectedDateTime().millisecondsSinceEpoch;
                      }
                      newNote.location = jsonEncode(location);
                    });
                  }
                },
                child: Text('Location: ${newNote.location}'),
              ),
              Divider(
                color: AdaptiveTheme.of(context).theme.colorScheme.onSurface,
              ),
              TextField(
                style: TextStyle(
                  color: AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                ),
                maxLines: null,
                onChanged: (String content) {
                  setState(() {
                    newNote.content = content;
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
            'New Note',
            style: TextStyle(
                color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                newNote.trimProperties();
                if (newNote.title.isEmpty) {
                  newNote.title = DateTime.now().toString().substring(5, 19);
                }
                if (!await newNote.exists()) {
                  if (newNote.from == 0 &&
                      newNote.to == 0 &&
                      newNote.location == '') {
                    newNote.active = 0;
                  } else {
                    newNote.active = 0;
                  }
                  newNote.dateModified = DateTime.now().millisecondsSinceEpoch;
                  await newNote.insert();
                  if (context.mounted) Navigator.pop(context);
                } else {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('Error'),
                        content:
                            Text('Note with the same title already exists.'),
                      ),
                    );
                  }
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
