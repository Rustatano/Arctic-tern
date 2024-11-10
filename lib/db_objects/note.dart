import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  String title;
  String category;
  String content;
  String dateModified;
  String timeNotification;
  String locationNotification;
  //String weatherNotification;
  String notificationPeriod;

  Note({
    required this.title,
    required this.category,
    required this.content,
    required this.dateModified,
    required this.timeNotification,
    required this.locationNotification,
    //required this.weatherNotification,
    required this.notificationPeriod,
  });

  static Note toDefault() {
    return Note(
      title: '',
      category: 'Category',
      content: '',
      dateModified: '',
      timeNotification: '',
      locationNotification: '',
      //weatherNotification: '',
      notificationPeriod: '',
    );
  }

  Map<String, String> toMap() {
    return {
      'title': title,
      'category': category,
      'content': content,
      'dateModified': dateModified,
      'timeNotification': timeNotification,
      'locationNotification': locationNotification,
      //'weatherNotification': weatherNotification,
      'notificationPeriod': notificationPeriod,
    };
  }

  static Note fromMap(Map<String, Object?> map) {
    return Note(
      title: map['title'] as String,
      category: map['category'] as String,
      content: map['content'] as String,
      dateModified: map['dateModified'] as String,
      timeNotification: map['timeNotification'] as String,
      locationNotification: map['locationNotification'] as String,
      //weatherNotification: map['weatherNotification'] as String,
      notificationPeriod: map['notificationPeriod'] as String,
    );
  }

  Future<void> insert() async {
    final db = await getDB();
    db.insert(
      'note',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeNote(String title) async {
    final db = await getDB();
    db.delete(
      'note',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  static Future<List<Note>> getNotes(Map<String, String> filter) async {
    final db = await getDB();
    List<Map<String, Object?>> list;
    if (filter['category'] == 'No Category') {
      list = await db.query('note');
    } else {
      list = await db.query('note', where: 'category = ?', whereArgs: [filter['category']]);
    }
    return list.map((note) => Note.fromMap(note)).toList();
  }

  static Future<Database> getDB() async {
    final db = await openDatabase(
      version: 1,
      join(await getDatabasesPath(), 'note.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS note(title TEXT PRIMARY KEY, category TEXT, content TEXT, dateModified TEXT, timeNotification TEXT, locationNotification TEXT, weatherNotification TEXT, notificationPeriod TEXT)',
        );
      },
    );
    return db;
  }

  Future<bool> exists() async {
    final db = await getDB();
    final query = await db.query(
      'note',
      where: 'title = ?',
      whereArgs: [title],
    );
    return query.isNotEmpty;
  }

  void trimProperties() {
    title = title.trim();
    category = category.trim();
    content = content.trim();
  }
}
