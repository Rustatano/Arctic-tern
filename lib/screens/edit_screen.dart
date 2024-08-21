import 'package:flutter/material.dart';
import 'package:weatherNote/constants.dart';
import 'package:weatherNote/db_objects/note.dart';
import 'package:weatherNote/notifications/time_notification.dart';
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
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final date =
                              await showDateTimePicker(context: context, initialDate: editedNote.timeNotification);
                          setState(() {
                            editedNote.timeNotification = '';
                          });
                          if (date != null) {
                            setState(() {
                              editedNote.timeNotification =
                                  date.toString().substring(0, 16);
                            });
                          }
                        },
                        icon: const Icon(Icons.access_time),
                      ),
                      Text(
                        editedNote.timeNotification,
                        style: const TextStyle(fontSize: smallFontSize),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.pin_drop),
                      ),
                      Text(editedNote.locationNotification),
                    ],
                  ),
                ),
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
        backgroundColor: theme.colorScheme.primary,
        title: const Text('Edit'),
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
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
