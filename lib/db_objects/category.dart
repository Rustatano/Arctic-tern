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
      'category': category,
      'r': r,
      'g': g,
      'b': b,
    };
  }

  static DBCategory fromMap(Map<String, Object?> map) {
    return DBCategory(
      category: map['category'] as String,
      r: map['r'] as String,
      g: map['g'] as String,
      b: map['b'] as String,
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
      where: 'category = ?',
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
      join(await getDatabasesPath(), 'category.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS category(category TEXT PRIMARY KEY, r TEXT, g TEXT, b TEXT)',
        );
      },
    );
    return db;
  }

  static Future<bool> exists(String category) async {
    final db = await getDB();
    final query = await db.query(
      'category',
      where: 'category = ?',
      whereArgs: [category],
    );
    return query.isNotEmpty;
  }
}
