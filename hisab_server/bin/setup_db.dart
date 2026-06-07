import 'dart:io';
import 'package:mysql1/mysql1.dart';

void main() async {
  print('Connecting to MySQL host...');
  final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
  final port = int.tryParse(Platform.environment['DB_PORT'] ?? '3306') ?? 3306;
  final user = Platform.environment['DB_USER'] ?? 'root';
  final password = Platform.environment['DB_PASSWORD'];
  final dbName = Platform.environment['DB_NAME'] ?? 'hisab_app';

  // First connect without specifying database to create it
  final settingsWithoutDb = ConnectionSettings(
    host: host,
    port: port,
    user: user,
    password: password,
  );

  MySqlConnection? conn;
  try {
    conn = await MySqlConnection.connect(settingsWithoutDb);
    print('Connected to MySQL server. Creating database if it does not exist...');
    await conn.query('CREATE DATABASE IF NOT EXISTS $dbName');
    await conn.close();

    // Now connect to the database to create tables
    final settingsWithDb = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: dbName,
    );

    conn = await MySqlConnection.connect(settingsWithDb);
    print('Connected to database "$dbName". Creating tables...');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS companies (
        id INT AUTO_INCREMENT PRIMARY KEY,
        company_name VARCHAR(255) NOT NULL,
        business_type VARCHAR(255) DEFAULT 'General'
      ) ENGINE=InnoDB;
    ''');
    print('- Created "companies" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS branches (
        id INT AUTO_INCREMENT PRIMARY KEY,
        company_id INT NOT NULL,
        name VARCHAR(255) NOT NULL,
        location VARCHAR(255) DEFAULT 'Unknown',
        cashier_name VARCHAR(255) DEFAULT 'Not Assigned'
      ) ENGINE=InnoDB;
    ''');
    print('- Created "branches" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS users (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL,
        company_id INT NOT NULL,
        branch_id INT NULL,
        FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
      ) ENGINE=InnoDB;
    ''');
    print('- Created "users" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS product_attributes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        company_id INT NOT NULL,
        attribute_name VARCHAR(255) NOT NULL
      ) ENGINE=InnoDB;
    ''');
    print('- Created "product_attributes" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS products (
        id INT AUTO_INCREMENT PRIMARY KEY,
        branch_id INT NOT NULL,
        name VARCHAR(255) NOT NULL,
        brand VARCHAR(255) DEFAULT '',
        category VARCHAR(255) DEFAULT '',
        specification VARCHAR(255) DEFAULT '',
        cost_price DOUBLE NOT NULL DEFAULT 0.0,
        selling_price DOUBLE NOT NULL DEFAULT 0.0,
        current_stock INT NOT NULL DEFAULT 0,
        total_inventory INT NOT NULL DEFAULT 0,
        low_stock_alert INT NOT NULL DEFAULT 5,
        high_stock_alert INT NOT NULL DEFAULT 10,
        is_deleted INT NOT NULL DEFAULT 0
      ) ENGINE=InnoDB;
    ''');
    print('- Created "products" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS inventory_transactions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        product_id INT NOT NULL,
        user_id BIGINT NOT NULL,
        type VARCHAR(50) NOT NULL,
        quantity INT NOT NULL,
        cost_price_at_transaction DOUBLE NULL,
        selling_price_at_transaction DOUBLE NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB;
    ''');
    print('- Created "inventory_transactions" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS staff (
        id INT AUTO_INCREMENT PRIMARY KEY,
        branch_id INT NOT NULL,
        name VARCHAR(255) NOT NULL,
        role VARCHAR(255) DEFAULT 'Staff',
        phone_number VARCHAR(50) DEFAULT '',
        total_units_sold INT DEFAULT 0,
        sold_items_summary JSON NULL
      ) ENGINE=InnoDB;
    ''');
    print('- Created "staff" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS sales (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        branch_id INT NOT NULL,
        user_id BIGINT NOT NULL,
        staff_id INT NOT NULL,
        total_amount DOUBLE NOT NULL,
        customer_name VARCHAR(255) DEFAULT 'Walk-in',
        sale_date DATETIME NOT NULL
      ) ENGINE=InnoDB;
    ''');
    print('- Created "sales" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS sale_items (
        sale_id BIGINT NOT NULL,
        product_id INT NOT NULL,
        quantity INT NOT NULL,
        price_at_sale DOUBLE NOT NULL,
        cost_price_at_sale DOUBLE NOT NULL,
        PRIMARY KEY (sale_id, product_id)
      ) ENGINE=InnoDB;
    ''');
    print('- Created "sale_items" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS daily_reports (
        id INT AUTO_INCREMENT PRIMARY KEY,
        branch_id INT NOT NULL,
        report_date DATE NOT NULL,
        total_income DOUBLE NOT NULL DEFAULT 0.0,
        total_branch_costs DOUBLE NOT NULL DEFAULT 0.0,
        total_units_sold INT NOT NULL DEFAULT 0,
        product_summary_json JSON NULL,
        staff_sales_json JSON NULL,
        status VARCHAR(50) DEFAULT 'Pending',
        UNIQUE KEY unique_branch_date (branch_id, report_date)
      ) ENGINE=InnoDB;
    ''');
    print('- Created "daily_reports" table');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS branch_costs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        branch_id INT NOT NULL,
        description VARCHAR(255) NOT NULL,
        amount DOUBLE NOT NULL,
        expense_date DATE NOT NULL
      ) ENGINE=InnoDB;
    ''');
    print('- Created "branch_costs" table');

    print('✅ Database schema setup completed successfully!');
  } catch (e) {
    print('❌ Error setting up database: $e');
    print('Make sure your local MySQL/XAMPP server is running and accessible.');
  } finally {
    if (conn != null) {
      await conn.close();
    }
  }
}
