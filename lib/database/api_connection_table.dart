import 'dart:async';
import 'package:n6picking_flutterapp/models/api_connection_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ApiConnectionDatabase {
  static final ApiConnectionDatabase instance = ApiConnectionDatabase._init();
  static Database? _database;

  ApiConnectionDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('N6PickingApiConnection.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const datetimeType = 'DATETIME NULL';

    await db.execute(
      '''
    CREATE TABLE $tableApiConnection (
    ${ApiConnectionFields.id} $idType,
    ${ApiConnectionFields.url} $textType,
    ${ApiConnectionFields.port} $textType,
    ${ApiConnectionFields.connectionString} $textType,
    ${ApiConnectionFields.lastConnection} $datetimeType
    )
    ''',
    );
  }

  Future<ApiConnection> create(ApiConnection apiConnection) async {
    final db = await instance.database;
    final id = await db.insert(tableApiConnection, apiConnection.toJson());

    return apiConnection.copy(id: id);
  }

  Future<ApiConnection?> update(ApiConnection apiConnection) async {
    final db = await instance.database;
    final id = await db.update(
      tableApiConnection,
      apiConnection.toJson(),
      where: '${ApiConnectionFields.id} = ?',
      whereArgs: [apiConnection.id],
    );

    return apiConnection.copy(id: id);
  }

  Future<ApiConnection?> read(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableApiConnection,
      columns: ApiConnectionFields.allValues,
      where: '${ApiConnectionFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ApiConnection.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<ApiConnection?> readFirst() async {
    final db = await instance.database;

    final maps = await db.query(
      tableApiConnection,
      columns: ApiConnectionFields.allValues,
    );

    if (maps.isNotEmpty) {
      return ApiConnection.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteAll() async {
    final db = await instance.database;

    return db.delete(
      tableApiConnection,
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
