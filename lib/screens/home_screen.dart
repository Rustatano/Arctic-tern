import 'package:adaptive_theme/adaptive_theme.dart';
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
    'category': 'All Categories',
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
          foregroundColor:
              AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
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
            if (context.mounted) FocusScope.of(context).unfocus();
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
                style: TextStyle(
                  color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
                ),
                maxLines: 1,
                onChanged: (String search) async {
                  setState(() {
                    getNotesFilter['searchQuery'] = search;
                  });
                  await getNotes(getNotesFilter);
                },
                decoration: InputDecoration(
                  fillColor:
                      AdaptiveTheme.of(context).theme.colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(radius),
                    ),
                  ),
                  hintText: 'Search notes',
                  hintStyle: TextStyle(
                      color: AdaptiveTheme.of(context)
                          .theme
                          .colorScheme
                          .onSurface),
                  prefixIcon: Icon(Icons.search,
                      color: AdaptiveTheme.of(context)
                          .theme
                          .colorScheme
                          .onSurface),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 35),
              child: Align(
                alignment: Alignment.centerRight,
                child: DropdownButton(
                  dropdownColor:
                      AdaptiveTheme.of(context).theme.colorScheme.primary,
                  hint: Text(
                    "Filter ",
                    style: TextStyle(
                      color:
                          AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                    ),
                  ),
                  icon: Icon(
                    Icons.filter_alt,
                    color:
                        AdaptiveTheme.of(context).theme.colorScheme.onSurface,
                  ),
                  onChanged: (filter) async {
                    if (filter == 'Oldest' || filter == 'Newest') {
                      setState(() {
                        getNotesFilter['dateModified'] = filter!;
                      });
                    }
                    await getNotes(getNotesFilter);
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'Oldest',
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .onPrimary,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: halfPadding),
                            child: Text(
                              'Oldest',
                              style: TextStyle(
                                color: AdaptiveTheme.of(context)
                                    .theme
                                    .colorScheme
                                    .onPrimary,
                              ),
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
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .onPrimary,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: halfPadding),
                            child: Text(
                              'Newest',
                              style: TextStyle(
                                color: AdaptiveTheme.of(context)
                                    .theme
                                    .colorScheme
                                    .onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  underline: Divider(
                    height: 0,
                    color: AdaptiveTheme.of(context).theme.colorScheme.surface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(padding),
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int index) {
                  var currentNote = notes[index];
                  return GestureDetector(
                    // animation would be nice here
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteInfoScreen(
                            note: currentNote,
                          ),
                        ),
                      );
                      await getNotes(getNotesFilter);
                      await getDBCategories();
                      if (context.mounted) FocusScope.of(context).unfocus();
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
                                      .cancelByUniqueName(currentNote.title);
                                  await Note.remove(currentNote.title);
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
                      child: Stack(
                        children: [
                          Material(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(radius),
                            ),
                            elevation: 3,
                            color: Colors.black, // note preview shadow color
                            child: Container(
                              decoration: BoxDecoration(
                                color: AdaptiveTheme.of(context)
                                    .theme
                                    .colorScheme
                                    .secondary,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(radius),
                                ),
                              ),
                              height: 75,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: padding,
                                  top: halfPadding,
                                  right: halfPadding,
                                  bottom: halfPadding,
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        (currentNote.title.length > 21)
                                            ? '${currentNote.title.substring(0, 20).trim()}...'
                                            : currentNote.title,
                                        style: TextStyle(
                                          fontSize: mediumFontSize,
                                          color: AdaptiveTheme.of(context)
                                              .theme
                                              .colorScheme
                                              .onSecondary,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        (currentNote.content
                                                    .split('\n')
                                                    .first
                                                    .length >
                                                25)
                                            ? '${currentNote.dateModified} ${currentNote.content.isEmpty ? "" : " | "} ${currentNote.content.split('\n').first.substring(0, 24).trim()}...'
                                            : '${currentNote.dateModified} ${currentNote.content.isEmpty ? "" : " | "} ${currentNote.content.split('\n').first}',
                                        style: TextStyle(
                                          color: AdaptiveTheme.of(context)
                                              .theme
                                              .colorScheme
                                              .onSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Material(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(radius),
                              bottomLeft: Radius.circular(radius),
                            ),
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .onSurface,
                            child: Container(
                              decoration: BoxDecoration(
                                color: getCategoryColor(currentNote.category),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(radius),
                                  bottomLeft: Radius.circular(radius),
                                ),
                              ),
                              height: 75,
                              width: 15,
                            ),
                          ),
                        ],
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
                var darkMode = (await AdaptiveTheme.getThemeMode())?.isDark;
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(darkMode: darkMode!),
                  ),
                );
                await getNotes(getNotesFilter);
                if (context.mounted) FocusScope.of(context).unfocus();
              },
              icon: Icon(
                Icons.settings,
                color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
              )),
          backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
          // Category selection, home screen
          title: DropdownButton(
            dropdownColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
            underline: Divider(
              color: AdaptiveTheme.of(context)
                  .theme
                  .colorScheme
                  .primary, // intentionall
              height: 0,
            ),
            iconEnabledColor:
                AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
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
                if (context.mounted) FocusScope.of(context).unfocus();
                if (!(await DBCategory.exists(getNotesFilter['category']!))) {
                  getNotesFilter['category'] = 'All Categories';
                }
                await getDBCategories();
              } else {
                setState(() {
                  getNotesFilter['category'] = category;
                });
              }
              await getNotes(getNotesFilter);
            },
          ),
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
                  style: TextStyle(
                    color:
                        AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
                  ),
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
          value: 'All Categories',
          child: Row(
            children: [
              Icon(
                Icons.all_inbox_rounded,
                color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
              ),
              Padding(
                padding: const EdgeInsets.only(left: halfPadding),
                child: Text(
                  'All Categories',
                  style: TextStyle(
                    color:
                        AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
                  ),
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
                color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
              ),
              Padding(
                padding: const EdgeInsets.only(left: halfPadding),
                child: Text(
                  'Manage',
                  style: TextStyle(
                    color:
                        AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return list.reversed.toList();
  }

  Color getCategoryColor(String category) {
    for (var cat in categories) {
      if (cat.category == category) {
        return Color.fromARGB(
          255,
          int.parse(cat.r),
          int.parse(cat.g),
          int.parse(cat.b),
        );
      }
    }
    return AdaptiveTheme.of(context).theme.colorScheme.secondary;
  }
}
