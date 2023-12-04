import 'dart:async';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('N6PickingProduct.db');

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
    const doubleType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    //const intType = 'INTEGER NOT NULL';

    await db.execute(
      '''
    CREATE TABLE $tableProduct (
    ${ProductFields.id} $textType,
    ${ProductFields.appId} $idType,
    ${ProductFields.erpId} $textType,
    ${ProductFields.reference} $textType,
    ${ProductFields.designation} $textType,
    ${ProductFields.unit} $textType,
    ${ProductFields.alternativeUnit} $textType,
    ${ProductFields.conversionFactor} $doubleType,
    ${ProductFields.isBatchTracked} $boolType,
    ${ProductFields.isSerialNumberTracked} $boolType
    )
    ''',
    );
  }

  Future<Product> create(Product product) async {
    final db = await instance.database;
    final id = await db.insert(tableProduct, product.toJson());

    return product.copy(appId: id);
  }

  Future<List<Product>> createBulk(List<Product> productList) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final product in productList) {
      batch.insert(tableProduct, product.toJson());
    }
    await batch.commit(noResult: true);
    return productList;
  }

  Future<Product?> read(String reference) async {
    final db = await instance.database;

    final result = await db.query(
      tableProduct,
      columns: ProductFields.allValues,
      where: '${ProductFields.reference} = ?',
      whereArgs: [reference],
    );

    if (result.isNotEmpty) {
      return Product.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<List<Product>> readAll() async {
    final db = await instance.database;
    final result = await db.query(
      tableProduct,
      columns: ProductFields.allValues,
    );

    if (result.isNotEmpty) {
      return result.map((json) => Product.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<Product?> readFirst() async {
    final db = await instance.database;

    final maps = await db.query(
      tableProduct,
      columns: ProductFields.allValues,
    );

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteAll() async {
    final db = await instance.database;

    return db.delete(
      tableProduct,
    );
  }

  Future<int> deleteBulk(List<Product> products) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final Product product in products) {
      batch.delete(
        tableProduct,
        where: '${ProductFields.reference} = ?',
        whereArgs: [product.reference],
      );
    }
    await batch.commit(noResult: true);
    return products.length;
  }

  Future<int> deleteAndCreateBulk(List<Product> products) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final Product product in products) {
      batch.delete(
        tableProduct,
        where: '${ProductFields.reference} = ?',
        whereArgs: [product.reference],
      );
      batch.insert(tableProduct, product.toJson());
    }
    await batch.commit(noResult: true);
    return products.length;
  }

  Future<int> delete(String reference) async {
    final db = await instance.database;

    return db.delete(
      tableProduct,
      where: '${ProductFields.reference} = ?',
      whereArgs: [reference],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
