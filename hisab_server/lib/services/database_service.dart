import 'dart:io';
import 'package:mysql1/mysql1.dart';

class DatabaseService {
  Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: Platform.environment['DB_HOST'] ?? '127.0.0.1',
      port: int.tryParse(Platform.environment['DB_PORT'] ?? '3306') ?? 3306,
      user: Platform.environment['DB_USER'] ?? 'root',
      password: Platform.environment['DB_PASSWORD'],
      db: Platform.environment['DB_NAME'] ?? 'hisab_app',
    );
    try {
      return await MySqlConnection.connect(settings);
    } catch (e) {
      print('Database Connection Error: $e');
      rethrow;
    }
  }
}
