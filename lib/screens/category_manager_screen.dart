import 'package:arctic_tern/constants.dart';
import 'package:arctic_tern/db_objects/categories.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

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
      categories = c.toList();
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
                    padding: const EdgeInsets.only(top: padding, left: padding, right: padding),
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
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.all(padding / 3),
                          child: Row(
                            children: [],
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.check,
            ),
          ),
        ],
      ),
    );
  }
}
