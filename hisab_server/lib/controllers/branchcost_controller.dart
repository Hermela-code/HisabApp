import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

class BranchCostController {

  Future<Response> addCost(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int? branchId = int.tryParse(data['branch_id'].toString());
      final String? description = data['description'];
      final String? amountRaw = data['amount']?.toString();

      if (branchId == null || description == null || description.isEmpty || amountRaw == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_id, description, and amount are required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final double amount = double.parse(amountRaw);
      final String date = data['date'] ?? DateTime.now().toString().split(' ')[0];

      final int? providedId = data['cost_id'] ?? data['id'];
      if (providedId != null) {
        await conn.query(
          'INSERT INTO branch_costs (id, branch_id, description, amount, expense_date) VALUES (?, ?, ?, ?, ?)',
          [providedId, branchId, description, amount, date],
        );
      } else {
        await conn.query(
          'INSERT INTO branch_costs (branch_id, description, amount, expense_date) VALUES (?, ?, ?, ?)',
          [branchId, description, amount, date],
        );
      }

      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Cost recorded'}),
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

  Future<Response> getDailyCosts(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final params = request.requestedUri.queryParameters;
      
      int? branchId;
      final routeParams = request.context['shelf_router/params'] as Map<String, String>?;
      if (routeParams != null && routeParams.containsKey('branchId')) {
        branchId = int.tryParse(routeParams['branchId']!);
      }

      if (branchId == null) {
        final String? branchIdRaw = params['branch_id'];
        if (branchIdRaw != null) {
          branchId = int.parse(branchIdRaw);
        }
      }

      if (branchId == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_id is required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final String? date = params['date'];

      var results;
      if (date != null && date.isNotEmpty) {
        results = await conn.query(
          'SELECT id, description, amount, expense_date, branch_id FROM branch_costs WHERE branch_id = ? AND expense_date = ?',
          [branchId, date],
        );
      } else {
        results = await conn.query(
          'SELECT id, description, amount, expense_date, branch_id FROM branch_costs WHERE branch_id = ?',
          [branchId],
        );
      }

      final costs = results.map((row) => {
        'id': row[0],
        'description': row[1] ?? '',
        'amount': row[2] ?? 0,
        'created_at': row[3].toString().split(' ')[0],
        'branch_id': row[4],
      }).toList();

      return Response.ok(
        jsonEncode(costs),
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

  Future<Response> deleteCost(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int costId = data['cost_id'];
      
      await conn.query('DELETE FROM branch_costs WHERE id = ?', [costId]);
      
      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Branch cost deleted successfully'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'content-type': 'application/json'}
      );
    } finally {
      await conn.close();
    }
  }
}
