import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

class SettingsController {
  Future<Response> defineProductAttributes(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int? companyId = int.tryParse(data['company_id'].toString());
      final List<dynamic>? attributes = data['attributes'];

      if (companyId == null || attributes == null || attributes.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'company_id and attributes are required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await conn.query('START TRANSACTION');
      for (var attr in attributes) {
        await conn.query(
          'INSERT INTO product_attributes (company_id, attribute_name) VALUES (?, ?)',
          [companyId, attr.toString()],
        );
      }
      await conn.query('COMMIT');

      return Response.ok(
        jsonEncode({'status': 'success'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      try { await conn.query('ROLLBACK'); } catch (_) {}
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    } finally {
      await conn.close();
    }
  }

  Future<Response> createBranch(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final String? branchName = data['branch_name'];
      final int? companyId = int.tryParse(data['company_id'].toString());
      final int? userId = int.tryParse(data['user_id'].toString());

      if (branchName == null || branchName.isEmpty ||
          companyId == null || userId == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_name, company_id, and user_id are required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      var result = await conn.query(
        'INSERT INTO branches (company_id, name) VALUES (?, ?)',
        [companyId, branchName],
      );
      final int newBranchId = result.insertId!;

      await conn.query('UPDATE users SET branch_id = ? WHERE id = ?', [newBranchId, userId]);

      return Response.ok(
        jsonEncode({'status': 'success', 'branch_id': newBranchId}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    } finally {
      await conn.close();
    }
  }
}
