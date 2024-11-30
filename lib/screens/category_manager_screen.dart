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
    return Scaffold(
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
                      controller: categoryNameTextFieldController,
                      maxLines: null,
                      onChanged: (String category) {
                        setState(() {
                          newCategory.category = category;
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a note title',
                        hintStyle: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await newCategory.insert();
                    await getDBCategories();
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: colorScheme.onSurface,
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
                          color: colorScheme.secondary,
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
                                      color: colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  List<Note> notes = await Note.getNotes(
                                      {'category': categories[index].category});
                                  for (var note in notes) {
                                    Note.remove(note.title);
                                  }
                                  DBCategory.removeDBCategory(
                                      categories[index].category);
                                  await getDBCategories();
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: colorScheme.onSecondary,
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
            color: colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ),
        backgroundColor: colorScheme.primary,
      ),
    );
  }
}
