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

      await conn.query(
        'INSERT INTO branch_costs (branch_id, description, amount, expense_date) VALUES (?, ?, ?, ?)',
        [branchId, description, amount, date],
      );

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
      final String? branchIdRaw = params['branch_id'];
      final String? date = params['date'];

      if (branchIdRaw == null || date == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_id and date query params are required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final int branchId = int.parse(branchIdRaw);

      var results = await conn.query(
        'SELECT id, description, amount, expense_date FROM branch_costs WHERE branch_id = ? AND expense_date = ?',
        [branchId, date],
      );

      final costs = results.map((row) => {
        'id': row['id'],
        'description': row['description'],
        'amount': row['amount'],
        'date': row['expense_date'].toString().split(' ')[0],
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
}
