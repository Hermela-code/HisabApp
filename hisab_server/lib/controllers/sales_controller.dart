import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

class SalesController {

  Future<Response> recordSale(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());

      final int branchId = (data['branch_id'] as num).toInt();
      final int userId = (data['user_id'] as num).toInt();
      final int staffId = (data['staff_id'] as num).toInt();
      final String customerName = data['customer_name'] ?? 'Walk-in';
      final List? items = data['items'];

      if (items == null || items.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_id, user_id, staff_id, and items are required'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final double totalAmount = (data['total_amount'] as num).toDouble();

      var staffCheck = await conn.query('SELECT id FROM staff WHERE id = ?', [staffId]);
      if (staffCheck.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'Invalid Staff ID'}),
          headers: {'content-type': 'application/json'},
        );
      }

      await conn.query('START TRANSACTION');

      print('DEBUG sales INSERT => branchId=$branchId userId=$userId staffId=$staffId totalAmount=$totalAmount customer=$customerName');

      var saleResult = await conn.query(
        'INSERT INTO sales (branch_id, user_id, staff_id, total_amount, customer_name, sale_date) VALUES (?, ?, ?, ?, ?, NOW())',
        [branchId, userId, staffId, totalAmount, customerName],
      );

      final int? saleId = saleResult.insertId;
      if (saleId == null) throw Exception('Failed to get Sale ID');

      int totalQtySoldInThisSale = 0;

      for (var item in items) {
        print('DEBUG raw item keys: ${(item as Map).keys.toList()}');
        print('DEBUG raw item values: ${item.values.toList()}');
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item);
        final int pId = (itemMap['product_id'] as num).toInt();
        final int qty = (itemMap['quantity'] as num).toInt();
        final double sPrice = (itemMap['price'] as num).toDouble();
        final double cPrice = (itemMap['cost'] as num).toDouble();

        print('DEBUG parsed => pId=$pId qty=$qty sPrice=$sPrice cPrice=$cPrice');

        if (pId == 0) throw Exception('Invalid Product ID detected in items list');

        // Stock-zero guard
        var stockCheck = await conn.query(
          'SELECT current_stock FROM products WHERE id = ?', [pId]
        );
        if (stockCheck.isEmpty) throw Exception('Product ID $pId not found');
        int currentStock = int.tryParse(stockCheck.first[0].toString()) ?? 0;
        if (currentStock < qty) {
          throw Exception('Insufficient stock for product ID $pId. Available: $currentStock, Requested: $qty');
        }

        totalQtySoldInThisSale += qty;

        await conn.query(
          'UPDATE products SET current_stock = current_stock - ? WHERE id = ?',
          [qty, pId],
        );

        var productRes = await conn.query('SELECT name FROM products WHERE id = ?', [pId]);
        String productName = productRes.first[0].toString();

        await conn.query('''
          UPDATE staff 
          SET sold_items_summary = JSON_SET(
            IFNULL(sold_items_summary, JSON_OBJECT()), 
            CONCAT('\$.', JSON_QUOTE(?)), 
            CAST(IFNULL(JSON_EXTRACT(sold_items_summary, CONCAT('\$.', JSON_QUOTE(?))), 0) AS UNSIGNED) + ?
          ) 
          WHERE id = ?
        ''', [productName, productName, qty, staffId]);

        await conn.query(
          'INSERT INTO sale_items (sale_id, product_id, quantity, price_at_sale, cost_price_at_sale) VALUES (?, ?, ?, ?, ?)',
          [saleId, pId, qty, sPrice, cPrice],
        );

        await conn.query(
          'INSERT INTO inventory_transactions (product_id, user_id, type, quantity) VALUES (?, ?, "sale", ?)',
          [pId, userId, qty],
        );
      }

      await conn.query(
        'UPDATE staff SET total_units_sold = IFNULL(total_units_sold, 0) + ? WHERE id = ?',
        [totalQtySoldInThisSale, staffId],
      );

      await conn.query('COMMIT');
      return Response.ok(
        jsonEncode({'status': 'success', 'sale_id': saleId}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e, stack) {
      print('DEBUG ERROR: $e');
      print('DEBUG STACK: $stack');
      try { await conn.query('ROLLBACK'); } catch (_) {}
      return Response.internalServerError(
        body: jsonEncode({'status': 'error', 'message': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    } finally {
      await conn.close();
    }
  }

  Future<Response> archiveDailyData(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();
    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int? branchId = data['branch_id'];
      if (branchId == null) {
        return Response.badRequest(
          body: jsonEncode({'status': 'error', 'message': 'branch_id is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      final String date = data['date'] ?? DateTime.now().toString().split(' ')[0];

      // Fixed column names: brand instead of model, specification instead of spec
      var productSummary = await conn.query('''
        SELECT p.name, p.brand, p.specification, SUM(si.quantity) as qty, SUM(si.quantity * si.price_at_sale) as revenue
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        JOIN products p ON si.product_id = p.id
        WHERE s.branch_id = ? AND DATE(s.sale_date) = ?
        GROUP BY p.id
      ''', [branchId, date]);

      var staffSummary = await conn.query('''
        SELECT st.name as staff_name, p.name as prod_name, p.brand, p.specification, SUM(si.quantity) as qty
        FROM sale_items si
        JOIN sales s ON si.sale_id = s.id
        JOIN staff st ON s.staff_id = st.id
        JOIN products p ON si.product_id = p.id
        WHERE s.branch_id = ? AND DATE(s.sale_date) = ?
        GROUP BY st.id, p.id
      ''', [branchId, date]);

      var totals = await conn.query('''
        SELECT 
          (SELECT IFNULL(SUM(total_amount), 0) FROM sales WHERE branch_id = ? AND DATE(sale_date) = ?) as income,
          (SELECT IFNULL(SUM(amount), 0) FROM branch_costs WHERE branch_id = ? AND expense_date = ?) as costs,
          (SELECT IFNULL(SUM(si.quantity), 0) FROM sale_items si JOIN sales s ON si.sale_id = s.id WHERE s.branch_id = ? AND DATE(s.sale_date) = ?) as units
      ''', [branchId, date, branchId, date, branchId, date]);

      await conn.query('''
        INSERT INTO daily_reports 
        (branch_id, report_date, total_income, total_branch_costs, total_units_sold, product_summary_json, staff_sales_json, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'Pending')
        ON DUPLICATE KEY UPDATE 
          total_income = VALUES(total_income), 
          total_branch_costs = VALUES(total_branch_costs), 
          total_units_sold = VALUES(total_units_sold), 
          product_summary_json = VALUES(product_summary_json),
          staff_sales_json = VALUES(staff_sales_json)
      ''', [
        branchId, date,
        double.tryParse(totals.first[0].toString()) ?? 0.0,
        double.tryParse(totals.first[1].toString()) ?? 0.0,
        (double.tryParse(totals.first[2].toString()) ?? 0.0).round(),
        jsonEncode(productSummary.map((r) => {'name': r[0], 'brand': r[1], 'specification': r[2], 'qty': r[3], 'revenue': r[4]}).toList()),
        jsonEncode(staffSummary.map((r) => {'staff': r[0], 'product': r[1], 'brand': r[2], 'specification': r[3], 'qty': r[4]}).toList()),
      ]);

      return Response.ok(
        jsonEncode({'status': 'success'}),
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
