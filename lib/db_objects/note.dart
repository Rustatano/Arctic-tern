import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDB {
  String title;
  String category;
  String content;
  String dateModified; // make this DateTime
  String timeNotification; // provisional
  String locationNotification; // provisional
  String weatherNotification; // provisional

  NoteDB(
      {required this.title,
      required this.category,
      required this.content,
      required this.dateModified,
      required this.timeNotification,
      required this.locationNotification,
      required this.weatherNotification});

  static NoteDB toDefault() {
    return NoteDB(
      title: '',
      category: '',
      content: '',
      dateModified: '',
      timeNotification: '',
      locationNotification: '',
      weatherNotification: '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'category': category,
      'content': content,
      'dateModified': dateModified,
      'timeNotification': timeNotification,
      'locationNotification': locationNotification,
      'weatherNotification': weatherNotification,
    };
  }

  static NoteDB fromMap(Map<String, Object?> map) {
    return NoteDB(
      title: map['title'] as String,
      category: map['category'] as String,
      content: map['content'] as String,
      dateModified: map['dateModified'] as String,
      timeNotification: map['timeNotification'] as String,
      locationNotification: map['locationNotification'] as String,
      weatherNotification: map['weatherNotification'] as String,
    );
  }

  Future<void> insertNoteDB() async {
    final db = await getDB();
    db.insert(
      'note',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeNoteDB() async {
    final db = await getDB();
    db.delete('note',
        where: 'title = ?',
        whereArgs: [title]); // make this to check more conditions
  }

  static Future<List<NoteDB>> getNotesDB() async {
    final db = await getDB();
    final list = await db.query('note');
    return list.map((e) => NoteDB.fromMap(e)).toList();
  }

  static Future<Database> getDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    final db = openDatabase(
      version: 1,
      join(await getDatabasesPath(), 'note.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE note(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, category TEXT, content TEXT, dateModified TEXT, timeNotification TEXT, locationNotification TEXT, weatherNotification TEXT)',
        );
      },
    );
    return db;
  }

  @override
  String toString() {
    return 'Notification{title: $title, category: $category, content: $content, dateModified: $dateModified, timeNotification: $timeNotification, locationNotification: $locationNotification, weatherNotification: $weatherNotification}';
  }
}
