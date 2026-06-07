import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

class StaffController {
  
  Future<Response> addStaff(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();

    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      
      final int branchId = data['branch_id'];
      final String name = data['name'];
      final String role = data['role'] ?? 'Cashier';
      // If your form includes a phone number field
      final String phone = data['phone'] ?? ''; 

      // We initialize total_units_sold to 0 and summary to an empty JSON object {}
      // This prevents 'NULL' math errors later during sales recording.
      final int? providedId = data['staff_id'] ?? data['id'];
      var result;
      if (providedId != null) {
        result = await conn.query(
          '''
          INSERT INTO staff (id, branch_id, name, role, phone_number, total_units_sold, sold_items_summary) 
          VALUES (?, ?, ?, ?, ?, 0, '{}')
          ''',
          [providedId, branchId, name, role, phone],
        );
      } else {
        result = await conn.query(
          '''
          INSERT INTO staff (branch_id, name, role, phone_number, total_units_sold, sold_items_summary) 
          VALUES (?, ?, ?, ?, 0, '{}')
          ''',
          [branchId, name, role, phone],
        );
      }

      print('Staff added successfully with ID: ${result.insertId}');

      return Response.ok(
        jsonEncode({
          'status': 'success', 
          'id': result.insertId,
          'message': 'Staff created with initialized performance tracking'
        }),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      print('Database Error in StaffController: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'}
      );
    } finally {
      await conn.close();
    }
  }

  Future<Response> getStaff(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      int? branchId;
      final routeParams = request.context['shelf_router/params'] as Map<String, String>?;
      if (routeParams != null && routeParams.containsKey('branchId')) {
        branchId = int.tryParse(routeParams['branchId']!);
      }

      if (branchId == null) {
        final params = request.requestedUri.queryParameters;
        branchId = int.tryParse(params['branch_id']?.toString() ?? '');
      }

      var results;
      if (branchId == null || branchId == 0) {
        results = await conn.query('SELECT id, name, phone_number, branch_id FROM staff');
      } else {
        results = await conn.query('SELECT id, name, phone_number, branch_id FROM staff WHERE branch_id = ?', [branchId]);
      }

      final staff = results.map((row) => {
        'id': row[0],
        'name': row[1] ?? '',
        'phone': row[2] ?? '',
        'phone_number': row[2] ?? '',
        'branch_id': row[3],
      }).toList();

      return Response.ok(
        jsonEncode(staff),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    } finally {
      await conn.close();
    }
  }

  Future<Response> deleteStaff(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int staffId = data['staff_id'];
      
      await conn.query('DELETE FROM staff WHERE id = ?', [staffId]);
      
      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Staff deleted successfully'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'}
      );
    } finally {
      await conn.close();
    }
  }
}