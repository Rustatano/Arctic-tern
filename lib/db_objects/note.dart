import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  String title;
  String category;
  String content;
  int dateModified;
  int from;
  int to;
  String location;
  //String repeat;
  int active;

  Note({
    required this.title,
    required this.category,
    required this.content,
    required this.dateModified,
    required this.from,
    required this.to,
    required this.location,
    //required this.repeat,
    required this.active,
  });

  static Note toDefault() {
    return Note(
      title: '',
      category: 'All Categories',
      content: '',
      dateModified: 0,
      from: 0,
      to: 0,
      location: '',
      //repeat: '',
      active: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_title': title,
      '_category': category,
      '_content': content,
      '_dateModified': dateModified,
      '_from': from,
      '_to': to,
      '_location': location,
      //'_repeat': repeat,
      '_active': active
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['_title'] as String,
      category: map['_category'] as String,
      content: map['_content'] as String,
      dateModified: int.parse(map['_dateModified'].toString()),
      from: int.parse(map['_from'].toString()),
      to: int.parse(map['_to'].toString()),
      location: map['_location'] as String,
      //repeat: map['_repeat'] as String,
      active: int.parse(map['_active'].toString()),
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

  static Future<void> remove(String title) async { // remove static?
    final db = await getDB();
    db.delete(
      'note',
      where: '_title = ?',
      whereArgs: [title],
    );
  }

  Future<void> update(Note newNote) async {
    remove(title);
    newNote.insert();
  }

  static Future<List<Note>> getNotes(Map<String, dynamic> filter) async {
    final db = await getDB();
    List<Map<String, Object?>> list;
    if (filter['category'] != 'All Categories') {
      list = await db.query('note',
          where: '_category = ?', whereArgs: [filter['category']]);
    } else if (filter['active'] == 1) {
      list = await db.query('note',
          where: '_active = ?', whereArgs: [1]);
    /*} else if (filter['from']) {
      list = await db.query('note', );
    } else if (filter['to']) {
      list = await db.query('note',
          where: '_active = ?', whereArgs: ['true']);*/
    } else {
      list = await db.query('note');
    }
    return list.map((note) => Note.fromMap(note)).toList();
  }

  static Future<Database> getDB() async {
    return await openDatabase(
      version: 1,
      join(await getDatabasesPath(), 'geoNote.db'),
    );
  }

  Future<bool> exists() async {
    final db = await getDB();
    final query = await db.query(
      'note',
      where: '_title = ?',
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
