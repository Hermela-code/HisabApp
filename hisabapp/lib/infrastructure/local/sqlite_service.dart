import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'hisab_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT,
        password TEXT,
        role TEXT,
        company_id INTEGER,
        branch_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE branches (
        id INTEGER PRIMARY KEY,
        name TEXT,
        company_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT,
        model TEXT,
        specification TEXT,
        stock INTEGER,
        unit_price INTEGER,
        branch_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE staff (
        id INTEGER PRIMARY KEY,
        name TEXT,
        phone TEXT,
        branch_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE branch_costs (
        id INTEGER PRIMARY KEY,
        branch_id INTEGER,
        description TEXT,
        amount INTEGER,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY,
        product_id INTEGER,
        product_name TEXT,
        salesperson TEXT,
        quantity INTEGER,
        unit_price INTEGER,
        total INTEGER,
        created_at TEXT,
        branch_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY,
        branch_id INTEGER,
        date TEXT,
        total_amount INTEGER,
        total_units INTEGER,
        total_products INTEGER,
        total_cost INTEGER,
        is_deposited INTEGER
      )
    ''');
  }
}
