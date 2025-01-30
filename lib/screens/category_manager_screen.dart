import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:arctic_tern/db_objects/note.dart';
import 'package:flutter/material.dart';

import 'package:arctic_tern/constants.dart';
import 'package:arctic_tern/db_objects/category.dart';

class CategoryManagerScreen extends StatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  List<DBCategory> categories = [];
  TextEditingController categoryNameTextFieldController =
      TextEditingController();
  DBCategory newCategory = DBCategory.toDefault();

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
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: padding, right: padding),
                      child: TextField(
                        style: TextStyle(
                          color: AdaptiveTheme.of(context)
                              .theme
                              .colorScheme
                              .onPrimary,
                        ),
                        controller: categoryNameTextFieldController,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter a note title',
                          hintStyle: TextStyle(
                            color: AdaptiveTheme.of(context)
                                .theme
                                .colorScheme
                                .onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (categoryNameTextFieldController.text == '' ||
                          categoryNameTextFieldController.text == 'All Categories') {
                        return;
                      } else {
                        newCategory.category = categoryNameTextFieldController.text;
                        categoryNameTextFieldController.clear();
                      }
                      var random = Random();
                      await newCategory.insert(
                        random.nextInt(156) + 100,
                        random.nextInt(156) + 100,
                        random.nextInt(156) + 100,
                      );
                      await getDBCategories();
                    },
                    child: Text(
                      'Add',
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
              Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(padding),
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(halfPadding / 2),
                      child: Material(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(radius),
                        ),
                        elevation: 3,
                        color: Colors.black,
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
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.all(padding / 3),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.square_rounded,
                                  color: Color.fromARGB(
                                    255,
                                    int.parse(categories[index].r),
                                    int.parse(categories[index].g),
                                    int.parse(categories[index].b),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: padding, right: padding),
                                    child: Text(
                                      categories[index].category,
                                      style: TextStyle(
                                        color: AdaptiveTheme.of(context)
                                            .theme
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    List<Note> notes = await Note.getNotes({
                                      'category': categories[index].category
                                    });
                                    for (var note in notes) {
                                      Note.remove(note.title);
                                    }
                                    DBCategory.removeDBCategory(
                                        categories[index].category);
                                    await getDBCategories();
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: AdaptiveTheme.of(context)
                                        .theme
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                              ],
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
        ),
        appBar: AppBar(
          title: Text(
            'Manage Categories',
            style: TextStyle(
              color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
            ),
          ),
          iconTheme: IconThemeData(
            color: AdaptiveTheme.of(context).theme.colorScheme.onPrimary,
          ),
          backgroundColor: AdaptiveTheme.of(context).theme.colorScheme.primary,
        ),
      ),
    );
  }
}
