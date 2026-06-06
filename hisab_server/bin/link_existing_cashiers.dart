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
    print('Connected to database. Checking for unassigned cashiers...');

    final cashiers = await conn.query('SELECT id, username FROM users WHERE role = ? AND branch_id IS NULL', ['cashier']);
    if (cashiers.isEmpty) {
      print('No cashiers found with NULL branch_id.');
      return;
    }

    for (final cashier in cashiers) {
      final userId = cashier[0];
      final username = cashier[1] as String;
      print('Found cashier: $username (ID: $userId)');

      final branchResults = await conn.query(
        'SELECT id, name FROM branches WHERE LOWER(cashier_name) = ?',
        [username.toLowerCase().trim()],
      );

      if (branchResults.isNotEmpty) {
        final branchId = branchResults.first[0];
        final branchName = branchResults.first[1];
        print('Matching branch found: $branchName (ID: $branchId)');

        await conn.query(
          'UPDATE users SET branch_id = ? WHERE id = ?',
          [branchId, userId],
        );
        print('Updated user $username to branch ID $branchId.');
      } else {
        print('No matching branch found for cashier name: $username');
      }
    }
    print('✅ Finished processing cashiers.');
  } catch (e) {
    print('Error: $e');
  } finally {
    if (conn != null) {
      await conn.close();
    }
  }
}
