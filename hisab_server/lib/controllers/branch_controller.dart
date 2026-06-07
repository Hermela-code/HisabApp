import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

class BranchController {

  Future<Response> getCompanyBranches(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      int? companyId;
      if (request.method == 'POST') {
        final bodyStr = await request.readAsString();
        if (bodyStr.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(bodyStr);
          companyId = int.tryParse(data['company_id']?.toString() ?? '');
        }
      } else {
        final params = request.requestedUri.queryParameters;
        companyId = int.tryParse(params['company_id']?.toString() ?? '');
      }

      var results;
      if (companyId != null) {
        results = await conn.query(
          'SELECT id, name, location, cashier_name, company_id FROM branches WHERE company_id = ?',
          [companyId],
        );
      } else {
        results = await conn.query(
          'SELECT id, name, location, cashier_name, company_id FROM branches',
        );
      }

      final branches = results.map((row) => {
        'id': row[0],
        'name': row[1],
        'branch_name': row[1],
        'location': row[2] ?? '',
        'cashier': row[3] ?? 'Not Assigned',
        'cashier_name': row[3] ?? 'Not Assigned',
        'company_id': row[4] ?? 1,
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

      final int? providedId = data['branch_id'] ?? data['id'];
      var result;
      if (providedId != null) {
        result = await conn.query(
          'INSERT INTO branches (id, company_id, name, location, cashier_name) VALUES (?, ?, ?, ?, ?)',
          [providedId, companyId, name, location, cashierName],
        );
      } else {
        result = await conn.query(
          'INSERT INTO branches (company_id, name, location, cashier_name) VALUES (?, ?, ?, ?)',
          [companyId, name, location, cashierName],
        );
      }

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

  Future<Response> updateBranch(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int? branchId = int.tryParse(data['branch_id']?.toString() ?? data['id']?.toString() ?? '');
      final String? name = data['branch_name'] ?? data['name'];
      final String? location = data['location'];
      final String? cashierName = data['cashier_name'] ?? data['cashier'];

      if (branchId == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_id is required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await conn.query(
        '''
        UPDATE branches 
        SET name = COALESCE(?, name), 
            location = COALESCE(?, location), 
            cashier_name = COALESCE(?, cashier_name)
        WHERE id = ?
        ''',
        [name, location, cashierName, branchId],
      );

      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Branch updated successfully'}),
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

  Future<Response> deleteBranch(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int? branchId = int.tryParse(data['branch_id']?.toString() ?? data['id']?.toString() ?? '');

      if (branchId == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_id is required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await conn.query(
        'DELETE FROM branches WHERE id = ?',
        [branchId],
      );

      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Branch deleted successfully'}),
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
