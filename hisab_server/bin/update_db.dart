import 'dart:io';
import 'package:mysql1/mysql1.dart';

void main() async {
  print('Connecting to MySQL database to migrate column types to BIGINT...');
  final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
  final port = int.tryParse(Platform.environment['DB_PORT'] ?? '3306') ?? 3306;
  final user = Platform.environment['DB_USER'] ?? 'root';
  final password = Platform.environment['DB_PASSWORD'];
  final dbName = Platform.environment['DB_NAME'] ?? 'hisab_app';

  final settings = ConnectionSettings(
    host: host,
    port: port,
    user: user,
    password: password,
    db: dbName,
  );

  MySqlConnection? conn;
  try {
    conn = await MySqlConnection.connect(settings);
    print('Connected successfully. Executing migrations...');

    // 1. Drop foreign key constraints that reference users(id) or sales(id)
    print('Dropping blocking foreign key constraints...');
    try {
      await conn.query('ALTER TABLE inventory_transactions DROP FOREIGN KEY inventory_transactions_ibfk_2');
      print('- Dropped "inventory_transactions_ibfk_2" constraint');
    } catch (e) {
      print('Note: could not drop inventory_transactions_ibfk_2: $e');
    }

    try {
      await conn.query('ALTER TABLE sales DROP FOREIGN KEY sales_ibfk_2');
      print('- Dropped "sales_ibfk_2" constraint');
    } catch (e) {
      print('Note: could not drop sales_ibfk_2: $e');
    }

    try {
      await conn.query('ALTER TABLE sale_items DROP FOREIGN KEY sale_items_ibfk_1');
      print('- Dropped "sale_items_ibfk_1" constraint');
    } catch (e) {
      print('Note: could not drop sale_items_ibfk_1: $e');
    }

    // 2. Modify columns to BIGINT
    print('Modifying column types to BIGINT...');
    await conn.query('ALTER TABLE users MODIFY COLUMN id BIGINT AUTO_INCREMENT');
    print('- Migrated "users.id" to BIGINT');

    await conn.query('ALTER TABLE sales MODIFY COLUMN id BIGINT AUTO_INCREMENT');
    print('- Migrated "sales.id" to BIGINT');

    await conn.query('ALTER TABLE sales MODIFY COLUMN user_id BIGINT');
    print('- Migrated "sales.user_id" to BIGINT');

    await conn.query('ALTER TABLE sale_items MODIFY COLUMN sale_id BIGINT');
    print('- Migrated "sale_items.sale_id" to BIGINT');

    await conn.query('ALTER TABLE inventory_transactions MODIFY COLUMN user_id BIGINT');
    print('- Migrated "inventory_transactions.user_id" to BIGINT');

    // 3. Re-create the foreign keys
    print('Re-creating foreign key constraints...');
    try {
      await conn.query('''
        ALTER TABLE inventory_transactions 
        ADD CONSTRAINT inventory_transactions_ibfk_2 
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ''');
      print('- Re-created "inventory_transactions_ibfk_2" constraint');
    } catch (e) {
      print('Note: could not re-create inventory_transactions_ibfk_2: $e');
    }

    try {
      await conn.query('''
        ALTER TABLE sales 
        ADD CONSTRAINT sales_ibfk_2 
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      ''');
      print('- Re-created "sales_ibfk_2" constraint');
    } catch (e) {
      print('Note: could not re-create sales_ibfk_2: $e');
    }

    try {
      await conn.query('''
        ALTER TABLE sale_items 
        ADD CONSTRAINT sale_items_ibfk_1 
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
      ''');
      print('- Re-created "sale_items_ibfk_1" constraint');
    } catch (e) {
      print('Note: could not re-create sale_items_ibfk_1: $e');
    }

    print('✅ Database columns migrated to BIGINT successfully!');
  } catch (e) {
    print('❌ Migration failed: $e');
  } finally {
    if (conn != null) {
      await conn.close();
    }
  }
}
