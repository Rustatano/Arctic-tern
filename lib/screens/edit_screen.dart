import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
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
    contentTextFieldController =
        TextEditingController(text: widget.note.content);
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
            TextField(
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
                editedNote.category = currentCategory;
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
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints.tight(Size(
                      MediaQuery.sizeOf(context).width,
                      MediaQuery.sizeOf(context).height * 0.33)),
                  backgroundColor: colorScheme.surface,
                  builder: (context) => Center(
                    child: DateTimePickerWidget(
                      initDateTime: getCorrectedDateTime(),
                      dateFormat: 'yyyy:MM:dd:HH:mm',
                      minuteDivider: 5,
                      onConfirm: (dateTime, selectedIndex) {
                        setState(() {
                          editedNote.from =
                              dateTime.toString().substring(0, 16);
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('From: ${editedNote.from}'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints.tight(Size(
                      MediaQuery.sizeOf(context).width,
                      MediaQuery.sizeOf(context).height * 0.33)),
                  backgroundColor: colorScheme.surface,
                  builder: (context) => Center(
                    child: DateTimePickerWidget(
                      initDateTime: getCorrectedDateTime(),
                      dateFormat: 'yyyy:MM:dd:HH:mm',
                      minuteDivider: 5,
                      onConfirm: (dateTime, selectedIndex) {
                        setState(() {
                          editedNote.to = dateTime.toString().substring(0, 16);
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('To: ${editedNote.to}'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () async {},
              child: Text('Repeat every: ${editedNote.repeat}'),
            ),
            const Divider(
              color: Colors.black,
            ),

            TextField(
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
              editedNote.trimProperties();
              if (editedNote.title.isEmpty) {
                editedNote.title = DateTime.now().toString().substring(5, 19);
              }

              if (editedNote.from != '' && editedNote.to != '' ||
                  editedNote.from == '' && editedNote.to == '') {
                // TODO: fix
                editedNote.active = 'true';
                await Note.removeNote(prevTitle);
                await editedNote.insert();
                setState(() {
                  contentTextFieldController.clear();
                  titleTextFieldController.clear();
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
