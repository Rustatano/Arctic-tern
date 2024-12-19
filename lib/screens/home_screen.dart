import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'package:arctic_tern/db_objects/category.dart';
import 'package:arctic_tern/screens/category_manager_screen.dart';
import 'package:arctic_tern/constants.dart';
import 'package:arctic_tern/db_objects/note.dart';
import 'package:arctic_tern/screens/new_note_screen.dart';
import 'package:arctic_tern/screens/note_info_screen.dart';
import 'package:arctic_tern/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  List<DBCategory> categories = [];
  Map<String, String> getNotesFilter = {
    'category': 'No Category',
    'searchQuery': '',
    'dateModified': 'Newest',
  };

  Future<void> getNotes(Map<String, String> filter) async {
    final n = (await Note.getNotes(filter)).reversed.toList();
    if (filter['searchQuery'] == '') {
      setState(() {
        notes = n;
      });
    } else {
      filter['searchQuery'] = filter['searchQuery']!.trim().toLowerCase();
      List<Note> searchedNotes = [];
      for (var note in n) {
        if (note.title.toLowerCase().contains(filter['searchQuery']!) ||
            note.content.toLowerCase().contains(filter['searchQuery']!)) {
          searchedNotes.add(note);
        }
      }
      setState(() {
        notes = searchedNotes;
      });
    }
    if (filter['dateModified'] == 'Oldest') {
      setState(() {
        notes = notes.reversed.toList();
      });
    }
  }

  Future<void> getDBCategories() async {
    final c = await DBCategory.getDBCategories();
    setState(() {
      categories = c;
    });
  }

  Future<void> askForPermission() async {
    if (!await Permission.notification
        .onDeniedCallback(() {
          openAppSettings();
        })
        .onGrantedCallback(() {})
        .onPermanentlyDeniedCallback(() {
          openAppSettings();
        })
        .onRestrictedCallback(() {
          openAppSettings();
        })
        .onLimitedCallback(() {
          openAppSettings();
        })
        .onProvisionalCallback(() {
          openAppSettings();
        })
        .request()
        .isGranted) {
      openAppSettings();
    }
    if (!await Permission.location
        .onDeniedCallback(() {
          openAppSettings();
        })
        .onGrantedCallback(() {})
        .onPermanentlyDeniedCallback(() {
          openAppSettings();
        })
        .onRestrictedCallback(() {
          openAppSettings();
        })
        .onLimitedCallback(() {
          openAppSettings();
        })
        .onProvisionalCallback(() {
          openAppSettings();
        })
        .request()
        .isGranted) {
      openAppSettings();
    }
    if (!await Permission.locationAlways
        .onDeniedCallback(() {
          openAppSettings();
        })
        .onGrantedCallback(() {})
        .onPermanentlyDeniedCallback(() {
          openAppSettings();
        })
        .onRestrictedCallback(() {
          openAppSettings();
        })
        .onLimitedCallback(() {
          openAppSettings();
        })
        .onProvisionalCallback(() {
          openAppSettings();
        })
        .request()
        .isGranted) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    askForPermission();
    getNotes(getNotesFilter);
    getDBCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            // await needed for proper notes refresh
            context,
            MaterialPageRoute(
              builder: (context) => NewNoteScreen(),
            ),
          );
          await getDBCategories();
          await getNotes(getNotesFilter);
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: padding,
                right: padding,
                top: halfPadding,
                bottom: halfPadding),
            child: TextField(
              maxLines: null,
              onChanged: (String search) async {
                setState(() {
                  getNotesFilter['searchQuery'] = search;
                });
                await getNotes(getNotesFilter);
              },
              decoration: InputDecoration(
                fillColor: colorScheme.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(radius),
                  ),
                ),
                hintText: 'Search notes',
                hintStyle: TextStyle(color: colorScheme.onSurface),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(padding),
              itemCount: notes.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  // animation would be nice here
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteInfoScreen(
                          note: notes[index],
                        ),
                      ),
                    );
                    await getNotes(getNotesFilter);
                    await getDBCategories();
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Note'),
                          content: const Text(
                              'Are you sure you want to delete this note? (cannot be undone)'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Workmanager()
                                    .cancelByUniqueName(notes[index].title);
                                await Note.remove(notes[index].title);
                                await getNotes(getNotesFilter);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  // Note preview
                  child: Padding(
                    padding: const EdgeInsets.all(halfPadding / 2),
                    child: Material(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(radius),
                      ),
                      elevation: 3,
                      color: Colors.black,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(radius),
                          ),
                        ),
                        height: 115,
                        child: Padding(
                          padding: const EdgeInsets.all(padding / 3),
                          child: Column(
                            children: [
                              Expanded(
                                child: Text(
                                  (notes[index].title.length > 21)
                                      ? '${notes[index].title.substring(0, 20).trim()}...'
                                      : notes[index].title,
                                  style: TextStyle(
                                    fontSize: mediumFontSize,
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  (notes[index].content.length > 21)
                                      ? '${notes[index].content.substring(0, 20).trim()}...'
                                      : notes[index].content,
                                  style: TextStyle(
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Badge(
                                        isLabelVisible: notes[index].from != '',
                                        label: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.access_time,
                                          color: colorScheme.onSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Badge(
                                        isLabelVisible:
                                            notes[index].location != '',
                                        label: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.pin_drop,
                                          color: colorScheme.onSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  /*
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Badge(
                                          isLabelVisible:
                                              notes[index].repeat != '',
                                          label: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.refresh,
                                            color: colorScheme.onSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    */
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              await getNotes(getNotesFilter);
            },
            icon: Icon(
              Icons.settings,
              color: colorScheme.onPrimary,
            )),
        backgroundColor: colorScheme.primary,
        // Category selection, home screen
        title: DropdownButton(
          dropdownColor: colorScheme.primary,
          value: getNotesFilter['category'],
          items: createDropDownMenuItemList(),
          onChanged: (String? category) async {
            if (category == null) return;
            if (category == 'Manage') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryManagerScreen(),
                ),
              );
              if (!(await DBCategory.exists(getNotesFilter['category']!))) {
                getNotesFilter['category'] = 'No Category';
              }
              await getDBCategories();
            } else if (category == 'Oldest' || category == 'Newest') {
              setState(() {
                getNotesFilter['dateModified'] = category;
              });
            } else {
              setState(() {
                getNotesFilter['category'] = category;
              });
            }
            await getNotes(getNotesFilter);
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> createDropDownMenuItemList() {
    List<DropdownMenuItem<String>> list = [];
    for (var i = 0; i < categories.length; i++) {
      list.add(
        DropdownMenuItem(
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
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    list.addAll(
      [
        DropdownMenuItem(
          value: 'No Category',
          child: Row(
            children: [
              Icon(
                Icons.all_inbox_rounded,
                color: colorScheme.onPrimary,
              ),
              Padding(
                padding: const EdgeInsets.only(left: halfPadding),
                child: Text(
                  'No Category',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Oldest',
          child: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                color: colorScheme.onPrimary,
              ),
              Padding(
                padding: const EdgeInsets.only(left: halfPadding),
                child: Text(
                  'Oldest',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Newest',
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                color: colorScheme.onPrimary,
              ),
              Padding(
                padding: const EdgeInsets.only(left: halfPadding),
                child: Text(
                  'Newest',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Manage',
          child: Row(
            children: [
              Icon(
                Icons.menu,
                color: colorScheme.onPrimary,
              ),
              Padding(
                padding: const EdgeInsets.only(left: halfPadding),
                child: Text(
                  'Manage',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return list.reversed.toList();
  }
}
