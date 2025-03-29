import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SavedLocation {
  String name;
  String location;
  int radius;

  SavedLocation({
    required this.name,
    required this.location,
    required this.radius,
  });

  static SavedLocation toDefault() {
    return SavedLocation(
      name: 'None',
      location: 'None',
      radius: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_name': name,
      '_location': location,
      '_radius': radius,
    };
  }

  static SavedLocation fromMap(Map<String, dynamic> map) {
    return SavedLocation(
      name: map['_name'] as String,
      location: map['_location'] as String,
      radius: map['_radius'] as int,
    );
  }

  Future<void> insert() async {
    final db = await getDB();
    db.insert(
      'savedLocation',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeSavedLocation(String name) async {
    final db = await getDB();
    db.delete(
      'savedLocation',
      where: '_name = ?',
      whereArgs: [name],
    );
  }

  static Future<List<SavedLocation>> getSavedLocation() async {
    final db = await getDB();
    final list = await db.query('savedLocation');
    return list.map((location) => SavedLocation.fromMap(location)).toList();
  }

  static Future<Database> getDB() async {
    return openDatabase(
      version: 1,
      join(await getDatabasesPath(), 'arcticTern.db'),
    );
  }

  static Future<bool> exists(String name) async {
    final db = await getDB();
    final query = await db.query(
      'savedLocation',
      where: '_name = ?',
      whereArgs: [name],
    );
    return query.isNotEmpty;
  }
}
