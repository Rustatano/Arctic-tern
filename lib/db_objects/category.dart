import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBCategory {
  String category;
  String r;
  String g;
  String b;

  DBCategory({
    required this.category,
    required this.r,
    required this.g,
    required this.b,
  });

  static DBCategory toDefault() {
    return DBCategory(
      category: '',
      r: '',
      g: '',
      b: '',
    );
  }

  Map<String, String> toMap() {
    return {
      '_category': category,
      '_r': r,
      '_g': g,
      '_b': b,
    };
  }

  static DBCategory fromMap(Map<String, Object?> map) {
    return DBCategory(
      category: map['_category'] as String,
      r: map['_r'] as String,
      g: map['_g'] as String,
      b: map['_b'] as String,
    );
  }

  Future<void> insert(int r, int g, int b) async {
    this.r = r.toString();
    this.g = g.toString();
    this.b = b.toString();
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
