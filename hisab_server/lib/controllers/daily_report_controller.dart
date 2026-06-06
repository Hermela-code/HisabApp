import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

class DailyReportController {
  
  // 1. MAIN FUNCTION: Generate Snapshot on "Export Today" Click
  Future<Response> generateSnapshot(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();

    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int branchId = data['branch_id'];
      final String date = DateTime.now().toString().split(' ')[0]; 

      // A. Live Income - Using the verified 'sale_date' column
      var incomeRes = await conn.query(
        'SELECT SUM(total_amount) FROM sales WHERE branch_id = ? AND DATE(sale_date) = ?',
        [branchId, date]
      );
      
      // B. Live Branch Costs
      var costRes = await conn.query(
        'SELECT SUM(amount) FROM branch_costs WHERE branch_id = ? AND expense_date = ?',
        [branchId, date]
      );
      
      // C. Live Units Sold 
      var unitsRes = await conn.query('''
        SELECT SUM(si.quantity) 
        FROM sale_items si 
        JOIN sales s ON si.sale_id = s.id 
        WHERE s.branch_id = ? AND DATE(s.sale_date) = ?
      ''', [branchId, date]);

      // D. Product breakdown for the Modal Table
      var productSummary = await conn.query('''
        SELECT p.name, p.brand, p.specification, SUM(si.quantity) as qty, SUM(si.quantity * si.price_at_sale) as revenue
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        JOIN products p ON si.product_id = p.id
        WHERE s.branch_id = ? AND DATE(s.sale_date) = ?
        GROUP BY p.id
      ''', [branchId, date]);

      // SAFE PARSING: Handles decimals like 21.0 to prevent radix-10 FormatException
      double liveIncome = double.parse((incomeRes.first[0] ?? 0).toString());
      double liveCosts = double.parse((costRes.first[0] ?? 0).toString());
      int liveUnits = double.parse((unitsRes.first[0] ?? 0).toString()).round();

      // 2. Update the Archive Table (daily_reports)
      await conn.query('''
        INSERT INTO daily_reports 
        (branch_id, report_date, total_income, total_branch_costs, total_units_sold, product_summary_json, status)
        VALUES (?, ?, ?, ?, ?, ?, 'Pending')
        ON DUPLICATE KEY UPDATE 
          total_income = VALUES(total_income), 
          total_branch_costs = VALUES(total_branch_costs), 
          total_units_sold = VALUES(total_units_sold),
          product_summary_json = VALUES(product_summary_json)
      ''', [
        branchId, 
        date, 
        liveIncome, 
        liveCosts, 
        liveUnits,
        jsonEncode(productSummary.map((r) => {
          'name': r[0], 
          'brand': r[1], 
          'model': r[1], 
          'specification': r[2], 
          'spec': r[2], 
          'qty': r[3], 
          'revenue': r[4]
        }).toList())
      ]);

      return Response.ok(jsonEncode({'status': 'success', 'message': 'Report updated for $date'}));

    } catch (e) {
      print("Snapshot Error: $e");
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    } finally {
      await conn.close();
    }
  }

  // 2. FUNCTION: Fetch archived reports for the list view
  Future<Response> getArchivedReports(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();

    try {
      final params = request.requestedUri.queryParameters;
      final int branchId = int.parse(params['branch_id'] ?? '0');
      final String viewType = params['view_type'] ?? 'cashier'; 

      var results;
      if (branchId == 0) {
        results = await conn.query('''
          SELECT id, report_date, total_income, total_branch_costs, total_units_sold, product_summary_json, status, branch_id 
          FROM daily_reports 
          ORDER BY report_date DESC
        ''');
      } else {
        results = await conn.query('''
          SELECT id, report_date, total_income, total_branch_costs, total_units_sold, product_summary_json, status, branch_id 
          FROM daily_reports 
          WHERE branch_id = ? 
          ORDER BY report_date DESC
        ''', [branchId]);
      }

      List reports = results.map((row) {
        final double income = double.tryParse(row['total_income']?.toString() ?? '0') ?? 0.0;
        final double costs = double.tryParse(row['total_branch_costs']?.toString() ?? '0') ?? 0.0;
        final int units = int.tryParse(row['total_units_sold']?.toString() ?? '0') ?? 0;
        final String status = row['status'] ?? 'Pending';
        final int isDeposited = (status == 'Deposited') ? 1 : 0;
        final int reportBranchId = row['branch_id'] ?? branchId;

        int totalProducts = 0;
        try {
          final summaryJson = row['product_summary_json'];
          if (summaryJson != null) {
            final decoded = jsonDecode(summaryJson.toString());
            if (decoded is List) {
              totalProducts = decoded.length;
            }
          }
        } catch (_) {}

        Map<String, dynamic> report = {
          'id': row['id'],
          'branch_id': reportBranchId,
          'date': row['report_date'].toString().split(' ')[0],
          'total_amount': income.toInt(),
          'income': income,
          'total_units': units,
          'units': units,
          'total_products': totalProducts,
          'total_cost': costs.toInt(),
          'costs': costs,
          'profit': income - costs,
          'is_deposited': isDeposited,
          'product_summary_json': row['product_summary_json'],
          'product_summary': row['product_summary_json'],
          'status': status, 
        };

        return report;
      }).toList();

      return Response.ok(jsonEncode(reports), headers: {'content-type': 'application/json'});
    } catch (e) {
      print("Fetch Archive Error: $e");
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    } finally {
      await conn.close();
    }
  }

  // 3. Mark as Deposited (Confirmation of funds)
  Future<Response> markAsDeposited(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final int id = int.parse(request.requestedUri.queryParameters['id']!);
      await conn.query('UPDATE daily_reports SET status = "Deposited" WHERE id = ?', [id]);
      return Response.ok(jsonEncode({'status': 'success'}));
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    } finally {
      await conn.close();
    }
  }
}