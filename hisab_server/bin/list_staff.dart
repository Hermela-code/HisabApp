import 'dart:io';
import 'package:mysql1/mysql1.dart';

void main() async {
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
    final results = await conn.query('SELECT id, name, role, phone_number, branch_id FROM staff');

    print('Staff in database:');
    for (final row in results) {
      print('ID: ${row[0]}, Name: ${row[1]}, Role: ${row[2]}, Phone: ${row[3]}, BranchID: ${row[4]}');
    }
  } catch (e) {
    print('Error listing staff: $e');
  } finally {
    if (conn != null) {
      await conn.close();
    }
  }
}
