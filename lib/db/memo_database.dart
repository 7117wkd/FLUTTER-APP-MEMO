import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/memo.dart';

class MemoDatabase {
  static Future<Database> _getDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'memo.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE memos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            created_at TEXT
          )
        ''');
      },
    );
  }

  static Future<int> updateMemo(Memo memo) async {
    final db = await _getDB();
    return await db.update(
      'memos',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }


  static Future<int> insertMemo(Memo memo) async {
    final db = await _getDB();
    return await db.insert('memos', memo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Memo>> getMemos() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps =
    await db.query('memos', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Memo.fromMap(maps[i]));
  }

  static Future<int> deleteMemo(int id) async {
    final db = await _getDB();
    return await db.delete('memos', where: 'id = ?', whereArgs: [id]);
  }
}
