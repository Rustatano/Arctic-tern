import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  String title;
  String category;
  String content;
  String dateModified; // make this DateTime
  String timeNotification; // provisional, this won't be String
  String locationNotification; // provisional, this won't be String
  String weatherNotification; // provisional, this won't be String

  Note(
      {required this.title,
      required this.category,
      required this.content,
      required this.dateModified,
      required this.timeNotification,
      required this.locationNotification,
      required this.weatherNotification});

  static Note toDefault() {
    return Note(
      title: '',
      category: 'Category',
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

  static Note fromMap(Map<String, Object?> map) {
    return Note(
      title: map['title'] as String,
      category: map['category'] as String,
      content: map['content'] as String,
      dateModified: map['dateModified'] as String,
      timeNotification: map['timeNotification'] as String,
      locationNotification: map['locationNotification'] as String,
      weatherNotification: map['weatherNotification'] as String,
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

  Future<bool> insertIfNotExists() async {
    final db = await getDB();
    if (await exists(title)) {
      return false;
    }
    db.insert(
      'note',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  static Future<void> removeNote(String title) async {
    final db = await getDB();
    db.delete(
      'note',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  static Future<List<Note>> getNotes() async {
    final db = await getDB();
    final list = await db.query('note');
    return list.map((e) => Note.fromMap(e)).toList();
  }

  static Future<Database> getDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    final db = openDatabase(
      version: 1,
      join(await getDatabasesPath(), 'note.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE note(title TEXT PRIMARY KEY, category TEXT, content TEXT, dateModified TEXT, timeNotification TEXT, locationNotification TEXT, weatherNotification TEXT)',
        );
      },
    );
    return db;
  }

  static Future<bool> exists(String title) async {
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
    dateModified = dateModified.trim();
    timeNotification = timeNotification.trim();
    locationNotification = locationNotification.trim();
    weatherNotification = weatherNotification.trim();
  }

  @override
  String toString() {
    return 'Notification{title: $title, category: $category, content: $content, dateModified: $dateModified, timeNotification: $timeNotification, locationNotification: $locationNotification, weatherNotification: $weatherNotification}';
  }
}
