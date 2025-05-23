import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserInfo {
  int darkMode;

  UserInfo({
    required this.darkMode,
  });

  static UserInfo toDefault() {
    return UserInfo(
      darkMode: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_darkMode': darkMode,
    };
  }

  static UserInfo fromMap(Map<String, dynamic> map) {
    return UserInfo(
      darkMode: map['_darkMode'] as int,
    );
  }

  Future<void> insert() async {
    final db = await getDB();
    db.insert(
      'userInfo',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeUserInfo(int darkMode) async {
    final db = await getDB();
    db.delete(
      'userInfo',
      where: '_darkMode = ?',
      whereArgs: [darkMode],
    );
  }

  static Future<List<UserInfo>> getUserInfo() async {
    final db = await getDB();
    final list = await db.query('userInfo');
    return list.map((userInfo) => UserInfo.fromMap(userInfo)).toList();
  }

  static Future<Database> getDB() async {
    return openDatabase(
      version: 1,
      join(await getDatabasesPath(), 'arcticTern.db'),
    );
  }

  static Future<bool> exists(String darkMode) async {
    final db = await getDB();
    final query = await db.query(
      'userInfo',
      where: '_darkMode = ?',
      whereArgs: [darkMode],
    );
    return query.isNotEmpty;
  }
}
