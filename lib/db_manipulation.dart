import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_location_time/db_objects/note.dart';

Future<Database> getDB() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = openDatabase(
    version: 1,
    join(await getDatabasesPath(), 'note.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE note(id INTEGER PRIMARY KEY, title TEXT, category TEXT, content TEXT, dateModified TEXT, timeNotification TEXT, locationNotification TEXT, weatherNotification TEXT)',
      );
    },
  );
  return db;
}

Future<void> insertNoteDB(NoteDB note) async {
  final db = await getDB();
  db.insert(
    'note',
    note.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<NoteDB>> getNotesDB() async {
  final db = await getDB();
  final list = await db.query('note');
  return list.map((e) => NoteDB.fromMap(e)).toList();
}