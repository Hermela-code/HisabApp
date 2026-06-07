import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    try {
      final path = join(await getDatabasesPath(), 'hisab_app.db');
      return await openDatabase(
        path,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      // Fallback to in-memory database if persistent database fails to open (e.g. web restrictions)
      return await openDatabase(
        inMemoryDatabasePath,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE branches ADD COLUMN location TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE branches ADD COLUMN cashier TEXT NOT NULL DEFAULT ""');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS product_attributes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE products ADD COLUMN category TEXT NOT NULL DEFAULT 'Mobile'",
      );
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE products ADD COLUMN cost_price INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE sales ADD COLUMN cost_total INTEGER NOT NULL DEFAULT 0');
      } catch (_) {}
    }
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
      CREATE TABLE businesses (
        id INTEGER PRIMARY KEY,
        name TEXT,
        type TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE branches (
        id INTEGER PRIMARY KEY,
        name TEXT,
        company_id INTEGER,
        location TEXT NOT NULL DEFAULT "",
        cashier TEXT NOT NULL DEFAULT ""
      )
    ''');

    await db.execute('''
      CREATE TABLE product_attributes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT,
        model TEXT,
        specification TEXT,
        category TEXT NOT NULL DEFAULT 'Mobile',
        stock INTEGER,
        unit_price INTEGER,
        cost_price INTEGER NOT NULL DEFAULT 0,
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
        cost_total INTEGER NOT NULL DEFAULT 0,
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
