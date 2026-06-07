import 'package:sqflite/sqflite.dart';

import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/app_repository.dart';
import '../local/sqlite_service.dart';

class SqliteAppRepository implements AppRepository {
  final SqliteService _sqlite;

  SqliteAppRepository(this._sqlite);

  Future<Database> get _db async => await _sqlite.db;

  @override
  Future<void> addBranch(Branch branch) async {
    final db = await _db;
    await db.insert('branches', {
      'id': branch.id,
      'name': branch.name,
      'company_id': branch.companyId,
      'location': branch.location,
      'cashier': branch.cashier,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    final db = await _db;
    await db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }

  @override
  Future<void> addProduct(Product product) async {
    final db = await _db;
    await db.insert('products', {
      'id': product.id,
      'name': product.name,
      'model': product.model,
      'specification': product.specification,
      'category': product.electronicsType,
      'stock': product.stock,
      'unit_price': product.unitPrice,
      'cost_price': product.costPrice,
      'branch_id': product.branchId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> addStaff(Staff staff) async {
    final db = await _db;
    await db.insert('staff', {
      'id': staff.id,
      'name': staff.name,
      'phone': staff.phone,
      'branch_id': staff.branchId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteStaff(int staffId) async {
    final db = await _db;
    await db.delete('staff', where: 'id = ?', whereArgs: [staffId]);
  }

  @override
  Future<void> addBranchCost(BranchCost cost) async {
    final db = await _db;
    await db.insert('branch_costs', {
      'id': cost.id,
      'branch_id': cost.branchId,
      'description': cost.title,
      'amount': cost.amount,
      'created_at': cost.createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteBranchCost(int costId) async {
    final db = await _db;
    await db.delete('branch_costs', where: 'id = ?', whereArgs: [costId]);
  }

  @override
  Future<void> addReport(Report report) async {
    final db = await _db;
    await db.insert('reports', {
      'id': report.id,
      'branch_id': report.branchId,
      'date': report.date,
      'total_amount': report.totalAmount,
      'total_units': report.totalUnits,
      'total_products': report.totalProducts,
      'total_cost': report.totalCost,
      'is_deposited': report.isDeposited ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<Branch>> getBranches() async {
    final db = await _db;
    final rows = await db.query('branches');
    return rows.map((row) => Branch(
      id: row['id'] as int,
      name: row['name'] as String,
      companyId: row['company_id'] as int,
      location: row['location'] as String? ?? '',
      cashier: row['cashier'] as String? ?? '',
    )).toList();
  }

  @override
  Future<List<String>> getProductAttributes() async {
    final db = await _db;
    final rows = await db.query('product_attributes', orderBy: 'id ASC');
    return rows.map((row) => row['name'] as String).toList();
  }

  @override
  Future<void> saveProductAttributes(List<String> attributes) async {
    final db = await _db;
    await db.delete('product_attributes');
    for (final name in attributes) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) continue;
      await db.insert('product_attributes', {'name': trimmed});
    }
  }

  @override
  Future<List<Product>> getProducts(int branchId) async {
    final db = await _db;
    final rows = branchId == 0
        ? await db.query('products')
        : await db.query('products', where: 'branch_id = ?', whereArgs: [branchId]);
    return rows.map((row) => Product(
      id: row['id'] as int,
      name: row['name'] as String,
      model: row['model'] as String,
      specification: row['specification'] as String,
      category: row['category'] as String? ?? ProductCategories.mobile,
      stock: row['stock'] as int,
      unitPrice: row['unit_price'] as int,
      costPrice: row['cost_price'] as int? ?? 0,
      branchId: row['branch_id'] as int,
    )).toList();
  }

  @override
  Future<List<Staff>> getStaff(int branchId) async {
    final db = await _db;
    final rows = branchId == 0
        ? await db.query('staff')
        : await db.query('staff', where: 'branch_id = ?', whereArgs: [branchId]);
    return rows.map((row) => Staff(
      id: row['id'] as int,
      name: row['name'] as String,
      phone: row['phone'] as String? ?? '',
      branchId: row['branch_id'] as int,
    )).toList();
  }

  @override
  Future<List<BranchCost>> getBranchCosts(int branchId) async {
    final db = await _db;
    final rows = await db.query('branch_costs', where: 'branch_id = ?', whereArgs: [branchId]);
    return rows.map((row) => BranchCost(
      id: row['id'] as int,
      branchId: row['branch_id'] as int,
      title: row['description'] as String,
      amount: row['amount'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
    )).toList();
  }

  @override
  Future<List<Sale>> getSales(int branchId) async {
    final db = await _db;
    final rows = await db.query('sales', where: 'branch_id = ?', whereArgs: [branchId]);
    return rows.map((row) => Sale(
      id: row['id'] as int,
      productId: row['product_id'] as int,
      productName: row['product_name'] as String,
      salesperson: row['salesperson'] as String,
      quantity: row['quantity'] as int,
      unitPrice: row['unit_price'] as int,
      total: row['total'] as int,
      costTotal: row['cost_total'] as int? ?? 0,
      createdAt: DateTime.parse(row['created_at'] as String),
      branchId: row['branch_id'] as int,
    )).toList();
  }

  @override
  Future<List<Report>> getReports() async {
    final db = await _db;
    final rows = await db.query('reports');
    return rows.map((row) => Report(
      id: row['id'] as int,
      branchId: row['branch_id'] as int,
      date: row['date'] as String,
      totalAmount: row['total_amount'] as int,
      totalUnits: row['total_units'] as int,
      totalProducts: row['total_products'] as int,
      totalCost: row['total_cost'] as int,
      isDeposited: (row['is_deposited'] as int) == 1,
    )).toList();
  }

  @override
  Future<User?> login(String username, String password) async {
    final db = await _db;
    final rows = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return User(
      id: row['id'] as int,
      username: row['username'] as String,
      password: row['password'] as String,
      role: row['role'] == 'cashier' ? UserRole.cashier : UserRole.owner,
      companyId: row['company_id'] as int,
      branchId: row['branch_id'] as int?,
    );
  }

  @override
  Future<void> markReportDeposited(int reportId) async {
    final db = await _db;
    await db.update('reports', {'is_deposited': 1}, where: 'id = ?', whereArgs: [reportId]);
  }

  @override
  Future<void> recordSale(Sale sale) async {
    final db = await _db;
    await db.insert('sales', {
      'id': sale.id,
      'product_id': sale.productId,
      'product_name': sale.productName,
      'salesperson': sale.salesperson,
      'quantity': sale.quantity,
      'unit_price': sale.unitPrice,
      'total': sale.total,
      'cost_total': sale.costTotal,
      'created_at': sale.createdAt.toIso8601String(),
      'branch_id': sale.branchId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    final rows = await db.query('products', where: 'id = ?', whereArgs: [sale.productId]);
    if (rows.isNotEmpty) {
      final product = rows.first;
      final newStock = (product['stock'] as int) - sale.quantity;
      await db.update('products', {'stock': newStock}, where: 'id = ?', whereArgs: [sale.productId]);
    }
  }

  @override
  Future<void> registerBusiness(String businessName, String businessType) async {
    final db = await _db;
    await db.insert('businesses', {
      'name': businessName,
      'type': businessType,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> signUp(User user) async {
    final db = await _db;
    await db.insert('users', {
      'id': user.id,
      'username': user.username,
      'password': user.password,
      'role': user.role == UserRole.cashier ? 'cashier' : 'owner',
      'company_id': user.companyId,
      'branch_id': user.branchId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
