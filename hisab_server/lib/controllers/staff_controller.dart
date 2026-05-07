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
      var result = await conn.query(
        '''
        INSERT INTO staff (branch_id, name, role, phone_number, total_units_sold, sold_items_summary) 
        VALUES (?, ?, ?, ?, 0, '{}')
        ''',
        [branchId, name, role, phone],
      );

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
}