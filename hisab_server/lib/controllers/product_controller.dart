import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/database_service.dart';

class ProductController {
  
  /// GET: Fetch stock list for a specific branch
  /// Only shows products where is_deleted = 0
  Future<Response> getBranchProducts(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();

    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int branchId = data['branch_id'];

      var results = await conn.query(
        '''
        SELECT id, name, brand, category, specification, selling_price, current_stock 
        FROM products 
        WHERE branch_id = ? AND is_deleted = 0
        ''',
        [branchId],
      );

      final products = results.map((row) => {
        'id': row[0],
        'name': row[1],
        'brand': row[2],
        'category': row[3],
        'specification': row[4],
        'selling_price': row[5],
        'units': row[6] 
      }).toList();

      return Response.ok(
        jsonEncode(products), 
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    } finally {
      await conn.close();
    }
  }

  /// POST: Create a brand new product entry
  Future<Response> addProduct(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();

    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      
      final int branchId = data['branch_id'];
      final String name = data['product_name'] ?? ''; 
      final String brand = data['brand'] ?? '';       
      final String category = data['category'] ?? ''; 
      final String spec = data['specification'] ?? ''; 
      
      final double sPrice = double.parse(data['selling_price'].toString());
      final double cPrice = double.parse(data['cost_price'].toString());
      final int stock = int.parse(data['total_stock'].toString());
      
      final int lowAlert = int.parse((data['low_stock_alert'] ?? '5').toString());
      final int highAlert = int.parse((data['high_stock_alert'] ?? '10').toString());

      var result = await conn.query(
        '''
        INSERT INTO products 
        (branch_id, name, brand, category, specification, cost_price, selling_price, current_stock, total_inventory, low_stock_alert, high_stock_alert, is_deleted) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
        ''',
        [branchId, name, brand, category, spec, cPrice, sPrice, stock, stock, lowAlert, highAlert],
      );

      return Response.ok(
        jsonEncode({'status': 'success', 'id': result.insertId}), 
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    } finally {
      await conn.close();
    }
  }

  /// POST: Edit an existing product
  Future<Response> editProduct(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();

    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      
      final int productId = data['product_id'];
      final String name = data['product_name'] ?? ''; 
      final String brand = data['brand'] ?? '';       
      final String category = data['category'] ?? ''; 
      final String spec = data['specification'] ?? ''; 
      
      final double sPrice = double.parse(data['selling_price'].toString());
      final double cPrice = double.parse(data['cost_price'].toString());
      final int stock = int.parse(data['total_stock'].toString());
      
      final int lowAlert = int.parse((data['low_stock_alert'] ?? '5').toString());
      final int highAlert = int.parse((data['high_stock_alert'] ?? '10').toString());

      await conn.query(
        '''
        UPDATE products 
        SET name = ?, brand = ?, category = ?, specification = ?, 
            cost_price = ?, selling_price = ?, current_stock = ?, 
            low_stock_alert = ?, high_stock_alert = ?
        WHERE id = ?
        ''',
        [name, brand, category, spec, cPrice, sPrice, stock, lowAlert, highAlert, productId],
      );

      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Product updated successfully'}), 
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    } finally {
      await conn.close();
    }
  }

  /// POST: Update stock for an existing product (Restock)
  Future<Response> updateStock(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();

    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      
      final int productId = data['product_id'];
      final int unitsToAdd = int.parse(data['units_to_add'].toString());
      final int userId = data['user_id'] ?? 1; 

      final double? newSellingPrice = data['new_selling_price'] != null 
          ? double.parse(data['new_selling_price'].toString()) : null;
      final double? newCostPrice = data['new_cost_price'] != null 
          ? double.parse(data['new_cost_price'].toString()) : null;

      await conn.query('START TRANSACTION');

      await conn.query(
        '''
        INSERT INTO inventory_transactions 
        (product_id, user_id, type, quantity, cost_price_at_transaction, selling_price_at_transaction) 
        VALUES (?, ?, 'restock', ?, ?, ?)
        ''',
        [productId, userId, unitsToAdd, newCostPrice, newSellingPrice],
      );

      String query = '''
        UPDATE products 
        SET current_stock = current_stock + ?, 
            total_inventory = total_inventory + ?
      ''';
      List<dynamic> params = [unitsToAdd, unitsToAdd];

      if (newSellingPrice != null) {
        query += ", selling_price = ?";
        params.add(newSellingPrice);
      }
      if (newCostPrice != null) {
        query += ", cost_price = ?";
        params.add(newCostPrice);
      }

      query += " WHERE id = ?";
      params.add(productId);

      await conn.query(query, params);
      await conn.query('COMMIT');
      
      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Stock and history updated.'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      try { await conn.query('ROLLBACK'); } catch (_) {}
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    } finally {
      await conn.close();
    }
  }

  /// DELETE: Soft delete a product
  Future<Response> deleteProduct(Request request) async {
    final db = DatabaseService();
    final conn = await db.getConnection();

    try {
      final Map<String, dynamic> data = jsonDecode(await request.readAsString());
      final int productId = data['product_id'];

      await conn.query(
        'UPDATE products SET is_deleted = 1 WHERE id = ?',
        [productId],
      );

      return Response.ok(
        jsonEncode({'status': 'success', 'message': 'Product archived successfully'}),
        headers: {'content-type': 'application/json'}
      );
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    } finally {
      await conn.close();
    }
  }
}