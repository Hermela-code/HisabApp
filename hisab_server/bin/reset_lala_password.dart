import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mysql1/mysql1.dart';

String _hash(String password) =>
    sha256.convert(utf8.encode(password)).toString();

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
    final hashedPassword = _hash('password123');

    // Update password and branch ID for lala
    await conn.query(
      'UPDATE users SET password = ?, branch_id = 11 WHERE username = ?',
      [hashedPassword, 'lala'],
    );
    print('✅ Successfully reset password for user "lala" to "password123" and set branch_id to 11.');
  } catch (e) {
    print('Error: $e');
  } finally {
    if (conn != null) {
      await conn.close();
    }
  }
}
