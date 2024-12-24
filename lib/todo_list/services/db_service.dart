import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' if (dart.library.html) 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../todo_item.dart';

class DBService {
  static Database? _db;
  
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    String path;
    if (kDebugMode && kIsWeb) {
      // Web调试模式
      path = 'todo_list.db';
    } else {
      // 移动端或生产环境
      final dbFolder = await getDatabasesPath();
      path = join(dbFolder, 'todo_list.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE todos (
            uuid TEXT PRIMARY KEY,
            id INTEGER,
            value TEXT,
            isChecked INTEGER,
            errorText TEXT,
            dueDate TEXT,
            note TEXT,
            reward TEXT,
            createTime TEXT,
            updateTime TEXT,
            syncStatus INTEGER
          )
        ''');
      },
    );
  }

  // 增加任务
  static Future<void> insertTodo(TodoItemMap todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 更新任务
  static Future<void> updateTodo(TodoItemMap todo) async {
    final db = await database;
    todo.updateTime = DateTime.now();
    todo.syncStatus = 2; // 标记需要同步
    await db.update(
      'todos',
      todo.toMap(),
      where: 'uuid = ?',
      whereArgs: [todo.uuid],
    );
  }

  // 删除任务
  static Future<void> deleteTodo(String uuid) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  // 获取所有任务
  static Future<List<TodoItemMap>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return TodoItemMap.fromMap(maps[i]);
    });
  }
} 