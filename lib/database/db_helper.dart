import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/password_item.dart';

class DBHelper {
  static const databaseName = "password_manager.db";
  static const databaseVersion = 3;

  // 表名和列名
  static const table = 'passwords';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnUsername = 'username';
  static const columnPassword = 'password';
  static const columnWebsite = 'website';
  
  static const columnNotes = 'notes';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';

  // 单例模式
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  // 数据库实例
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 创建表
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnUsername TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnWebsite TEXT,

            $columnNotes TEXT,
            $columnCreatedAt TEXT NOT NULL,
            $columnUpdatedAt TEXT NOT NULL
          )
          ''');
  }

  // 升级数据库
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // 移除email列
      await db.execute('''
        CREATE TABLE ${table}_temp (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnTitle TEXT NOT NULL,
          $columnUsername TEXT NOT NULL,
          $columnPassword TEXT NOT NULL,
          $columnWebsite TEXT,
          $columnNotes TEXT,
          $columnCreatedAt TEXT NOT NULL,
          $columnUpdatedAt TEXT NOT NULL
        )
      ''');

      // 复制数据（不包含email列）
      await db.execute('''
        INSERT INTO ${table}_temp ($columnId, $columnTitle, $columnUsername, $columnPassword, $columnWebsite, $columnNotes, $columnCreatedAt, $columnUpdatedAt)
        SELECT $columnId, $columnTitle, $columnUsername, $columnPassword, $columnWebsite, $columnNotes, $columnCreatedAt, $columnUpdatedAt
        FROM $table
      ''');

      // 删除旧表
      await db.execute('DROP TABLE $table');

      // 重命名临时表
      await db.execute('ALTER TABLE ${table}_temp RENAME TO $table');
    }
    if (oldVersion < 2) {
      // 创建临时表
      await db.execute('''
        CREATE TABLE ${table}_temp (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnTitle TEXT NOT NULL,
          $columnUsername TEXT NOT NULL,
          $columnPassword TEXT NOT NULL,
          $columnWebsite TEXT,

          $columnNotes TEXT,
          $columnCreatedAt TEXT NOT NULL,
          $columnUpdatedAt TEXT NOT NULL
        )
      ''');

      // 复制数据（将url数据复制到website列，email设置为NULL）
      await db.execute('''
        INSERT INTO ${table}_temp ($columnId, $columnTitle, $columnUsername, $columnPassword, $columnWebsite, $columnNotes, $columnCreatedAt, $columnUpdatedAt)
        SELECT $columnId, $columnTitle, $columnUsername, $columnPassword, url, $columnNotes, $columnCreatedAt, $columnUpdatedAt
        FROM $table
      ''');

      // 删除旧表
      await db.execute('DROP TABLE $table');

      // 重命名临时表
      await db.execute('ALTER TABLE ${table}_temp RENAME TO $table');
    }
  }

  // 插入新的密码条目
  Future<int> insert(PasswordItem item) async {
    Database db = await instance.database;
    return await db.insert(table, item.toMap());
  }

  // 获取所有密码条目
  Future<List<PasswordItem>> queryAllRows() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table, orderBy: '$columnTitle ASC');
    return List.generate(maps.length, (i) {
      return PasswordItem.fromMap(maps[i]);
    });
  }

  // 通过ID查询密码条目
  Future<PasswordItem?> queryRow(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PasswordItem.fromMap(maps.first);
    }
    return null;
  }

  // 更新密码条目
  Future<int> update(PasswordItem item) async {
    Database db = await instance.database;
    return await db.update(
      table,
      item.toMap(),
      where: '$columnId = ?',
      whereArgs: [item.id],
    );
  }

  // 删除密码条目
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // 搜索密码条目
  Future<List<PasswordItem>> search(String query) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '''$columnTitle LIKE ? OR $columnUsername LIKE ? OR $columnWebsite LIKE ?''',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: '$columnTitle ASC',
    );
    return List.generate(maps.length, (i) {
      return PasswordItem.fromMap(maps[i]);
    });
  }
}