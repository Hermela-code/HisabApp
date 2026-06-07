import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

String _hash(String password) =>
    sha256.convert(utf8.encode(password)).toString();

class AuthController {
  Future<Response> registerBusiness(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final String? companyName = data['business_name'];
      final String? businessType = data['business_type'];

      if (companyName == null || companyName.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'business_name is required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      var result = await conn.query(
        'INSERT INTO companies (company_name, business_type) VALUES (?, ?)',
        [companyName, businessType ?? 'General'],
      );

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'company_id': result.insertId,
          'message': 'Business profile created'
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

  Future<Response> signUp(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final String? username = data['username'];
      final String? password = data['password'];
      final String? role = data['role'];

      if (username == null || username.isEmpty ||
          password == null || password.isEmpty ||
          role == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'username, password, and role are required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await conn.transaction((ctx) async {
        // Query A: Insert a new default company
        final String companyName = data['company_name'] ?? data['business_name'] ?? 'My Business';
        final String businessType = data['business_type'] ?? 'General';
        final companyResult = await ctx.query(
          'INSERT INTO companies (company_name, business_type) VALUES (?, ?)',
          [companyName, businessType],
        );
        final int companyId = companyResult.insertId!;

        // Query B: Insert a new default branch using the companyId
        final String branchName = data['branch_name'] ?? 'Main Branch';
        final String location = data['location'] ?? 'Unknown';
        final String cashierName = (role == 'cashier' || role == 'Cashier') ? username : 'Not Assigned';
        final branchResult = await ctx.query(
          'INSERT INTO branches (company_id, name, location, cashier_name) VALUES (?, ?, ?, ?)',
          [companyId, branchName, location, cashierName],
        );
        final int branchId = branchResult.insertId!;

        // Query C: Insert the new user using the companyId and branchId
        final int? providedId = data['user_id'] ?? data['id'];
        if (providedId != null) {
          await ctx.query(
            'INSERT INTO users (id, username, password, role, company_id, branch_id) VALUES (?, ?, ?, ?, ?, ?)',
            [providedId, username, _hash(password), role, companyId, branchId],
          );
        } else {
          await ctx.query(
            'INSERT INTO users (username, password, role, company_id, branch_id) VALUES (?, ?, ?, ?, ?)',
            [username, _hash(password), role, companyId, branchId],
          );
        }
      });

      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Account successfully created!'}),
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

  Future<Response> login(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final String? username = data['username'];
      final String? password = data['password'];

      if (username == null || username.isEmpty ||
          password == null || password.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'username and password are required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      var results = await conn.query(
        'SELECT id, username, role, company_id, branch_id FROM users WHERE username = ? AND password = ?',
        [username, _hash(password)],
      );

      if (results.isEmpty) {
        return Response.forbidden(
          jsonEncode({'status': 'error', 'message': 'Invalid username or password'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final user = results.first;
      var branchId = user[4];
      if (branchId == null && (user[2] == 'cashier' || user[2] == 'Cashier')) {
        var branchResults = await conn.query(
          'SELECT id FROM branches WHERE LOWER(cashier_name) = ?',
          [username.toLowerCase().trim()],
        );
        if (branchResults.isNotEmpty) {
          branchId = branchResults.first[0];
          await conn.query(
            'UPDATE users SET branch_id = ? WHERE id = ?',
            [branchId, user[0]],
          );
        }
      }

      return Response.ok(
        jsonEncode({
          'status': 'success',
          'user_id': user[0],
          'username': user[1],
          'role': user[2],
          'company_id': user[3],
          'branch_id': branchId,
          'message': 'Login successful'
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
