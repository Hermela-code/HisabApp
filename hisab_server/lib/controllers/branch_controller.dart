import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

class BranchController {

  Future<Response> getCompanyBranches(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int? companyId = int.tryParse(data['company_id'].toString());

      if (companyId == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'company_id is required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      var results = await conn.query(
        'SELECT id, name, location, cashier_name FROM branches WHERE company_id = ?',
        [companyId],
      );

      final branches = results.map((row) => {
        'id': row[0],
        'branch_name': row[1],
        'location': row[2],
        'cashier_name': row[3] ?? 'Not Assigned',
      }).toList();

      return Response.ok(
        jsonEncode(branches),
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

  Future<Response> addBranch(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final String? name = data['branch_name'];
      final int? companyId = int.tryParse(data['company_id'].toString());

      if (name == null || name.isEmpty || companyId == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_name and company_id are required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final String location = data['location'] ?? 'Unknown';
      final String cashierName = data['cashier_name'] ?? 'Not Assigned';

      var result = await conn.query(
        'INSERT INTO branches (company_id, name, location, cashier_name) VALUES (?, ?, ?, ?)',
        [companyId, name, location, cashierName],
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'branch_id': result.insertId,
          'message': 'Branch $name saved!',
        }),
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
