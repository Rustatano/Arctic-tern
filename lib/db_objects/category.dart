import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBCategory {
  String category;
  int r;
  int g;
  int b;

  DBCategory({
    required this.category,
    required this.r,
    required this.g,
    required this.b,
  });

  static DBCategory toDefault() {
    return DBCategory(
      category: '',
      r: 0,
      g: 0,
      b: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_category': category,
      '_r': r,
      '_g': g,
      '_b': b,
    };
  }

  static DBCategory fromMap(Map<String, dynamic> map) {
    return DBCategory(
      category: map['_category'] as String,
      r: int.parse(map['_r'].toString()),
      g: int.parse(map['_g'].toString()),
      b: int.parse(map['_b'].toString()),
    );
  }

  Future<void> insert(int r, int g, int b) async {
    this.r = r;
    this.g = g;
    this.b = b;
    final db = await getDB();
    db.insert(
      'category',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeDBCategory(String category) async {
    final db = await getDB();
    db.delete(
      'category',
      where: '_category = ?',
      whereArgs: [category],
    );
  }

  static Future<List<DBCategory>> getDBCategories() async {
    final db = await getDB();
    final list = await db.query('category');
    return list.map((category) => DBCategory.fromMap(category)).toList();
  }

  static Future<Database> getDB() async {
    final db = await openDatabase(
      version: 1,
      join(await getDatabasesPath(), 'geoNote.db'),
    );
    return db;
  }

  static Future<bool> exists(String category) async {
    final db = await getDB();
    final query = await db.query(
      'category',
      where: '_category = ?',
      whereArgs: [category],
    );
    return query.isNotEmpty;
  }
}
