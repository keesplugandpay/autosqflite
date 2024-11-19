library autosqflite;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AutoSqfLite {
  final String databaseName;
  Database? _db;

  AutoSqfLite({required this.databaseName});

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, '$databaseName.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Initial database creation
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle migrations
      },
    );
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final tables = await db.query('sqlite_master', where: 'type = ? AND name = ?', whereArgs: ['table', tableName]);
    return tables.isNotEmpty;
  }

  Future<void> _updateDatabaseIfNeeded(Database db, String tableName, Map<String, dynamic> data) async {
    if (!await _tableExists(db, tableName)) {
      // Create table based on map structure
      await _createTableFromMap(db, tableName, data);
    } else {
      // Check for new columns
      await _addNewColumns(db, tableName, data);
    }
  }

  Future<void> _createTableFromMap(Database db, String tableName, Map<String, dynamic> data) async {
    final columns = _generateColumnDefinitions(data);

    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $columns
      )
    ''');
  }

  String _generateColumnDefinitions(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      final type = _getSqliteType(entry.value);
      return '${entry.key} $type';
    }).join(', ');
  }

  String _getSqliteType(dynamic value) {
    if (value is int) return 'INTEGER';
    if (value is double) return 'REAL';
    if (value is bool) return 'INTEGER';
    if (value is DateTime) return 'INTEGER';
    return 'TEXT';
  }

  Map<String, dynamic> _mapDataForDb(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is bool) {
        return MapEntry(key, value ? 1 : 0);
      }
      if (value is DateTime) {
        return MapEntry(key, value.millisecondsSinceEpoch);
      }
      return MapEntry(key, value);
    });
  }

  Future<void> _addNewColumns(Database db, String tableName, Map<String, dynamic> data) async {
    // Get existing columns
    final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
    final existingColumns = tableInfo.map((col) => col['name'] as String).toSet();

    // Add new columns
    for (final entry in data.entries) {
      if (!existingColumns.contains(entry.key)) {
        final type = _getSqliteType(entry.value);
        await db.execute('ALTER TABLE $tableName ADD COLUMN ${entry.key} $type');
      }
    }
  }

  Future<void> insert(String tableName, Map<String, dynamic> data) async {
    final db = await database;

    await _updateDatabaseIfNeeded(db, tableName, data);

    // Insert the data
    await db.insert(
      tableName,
      _mapDataForDb(data),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<Map<String, dynamic>?> get(String tableName, int id) async {
    final db = await database;

    if (!await _tableExists(db, tableName)) {
      return null;
    }

    final results = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(String tableName, Map<String, dynamic> data, int id) async {
    final db = await database;

    await _updateDatabaseIfNeeded(db, tableName, data);

    return await db.update(
      tableName,
      _mapDataForDb(data),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String tableName, int id) async {
    final db = await database;

    if (!await _tableExists(db, tableName)) {
      return 0;
    }

    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
