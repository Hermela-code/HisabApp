import 'dart:convert';
import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/app_repository.dart';
import '../local/sqlite_service.dart';
import '../remote/api_client.dart';

class CachedAppRepository implements AppRepository {
  final SqliteService _sqlite;
  final ApiClient _api;

  CachedAppRepository(this._sqlite, this._api);

  // --- Auth ---
  @override
  Future<User?> login(String username, String password) async {
    final db = await _sqlite.db;
    final res = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (res.isNotEmpty) {
      final row = res.first;
      return User(
        id: row['id'] as int,
        username: row['username'] as String,
        password: row['password'] as String,
        role: row['role'] == 'cashier' ? UserRole.cashier : UserRole.owner,
        companyId: row['company_id'] as int,
        branchId: row['branch_id'] as int?,
      );
    }

    // cache miss -> call API
    try {
      final Map<String, dynamic> data = await _api.post('/login', {'username': username, 'password': password});
      if (data['status'] == 'success') {
        final userId = data['user_id'] as int;
        final role = data['role'] as String;
        final companyId = data['company_id'] as int;
        final branchId = data['branch_id'] as int?;
        await db.insert('users', {'id': userId, 'username': username, 'password': password, 'role': role, 'company_id': companyId, 'branch_id': branchId});
        return User(id: userId, username: username, password: password, role: role == 'cashier' ? UserRole.cashier : UserRole.owner, companyId: companyId, branchId: branchId);
      }
    } catch (e) {
      // network error; return null
    }
    return null;
  }

  @override
  Future<void> signUp(User user) async {
    final db = await _sqlite.db;
    try {
      await _api.post('/signup', {'username': user.username, 'password': user.password, 'role': user.role == UserRole.cashier ? 'cashier' : 'owner', 'company_id': user.companyId});
    } catch (e) {
      // ignore network error but still write locally
    }
    await db.insert('users', {'id': user.id, 'username': user.username, 'password': user.password, 'role': user.role == UserRole.cashier ? 'cashier' : 'owner', 'company_id': user.companyId, 'branch_id': user.branchId});
  }

  // --- Branches ---
  @override
  Future<void> addBranch(Branch branch) async {
    final db = await _sqlite.db;
    await db.insert('branches', {'id': branch.id, 'name': branch.name, 'company_id': branch.companyId});
    try {
      await _api.post('/add-branch', {'name': branch.name, 'company_id': branch.companyId});
    } catch (_) {}
  }

  @override
  Future<List<Branch>> getBranches() async {
    final db = await _sqlite.db;
    final rows = await db.query('branches');
    if (rows.isNotEmpty) {
      return rows.map((r) => Branch(id: r['id'] as int, name: r['name'] as String, companyId: r['company_id'] as int)).toList();
    }
    // fallback to API
    try {
      final data = await _api.post('/get-branches', {});
      // expect returned list under 'branches'
      final list = (data['branches'] as List<dynamic>?) ?? [];
      final branches = list.map((e) => Branch(id: e['id'] as int, name: e['company_name'] as String, companyId: e['company_id'] as int)).toList();
      for (final b in branches) {
        await db.insert('branches', {'id': b.id, 'name': b.name, 'company_id': b.companyId});
      }
      return branches;
    } catch (_) {
      return [];
    }
  }

  // --- Products ---
  @override
  Future<void> addProduct(Product product) async {
    final db = await _sqlite.db;
    await db.insert('products', {'id': product.id, 'name': product.name, 'model': product.model, 'specification': product.specification, 'stock': product.stock, 'unit_price': product.unitPrice, 'branch_id': product.branchId});
    try {
      await _api.post('/add-product', {'name': product.name});
    } catch (_) {}
  }

  @override
  Future<List<Product>> getProducts(int branchId) async {
    final db = await _sqlite.db;
    final rows = await db.query('products', where: 'branch_id = ?', whereArgs: [branchId]);
    if (rows.isNotEmpty) {
      return rows.map((r) => Product(id: r['id'] as int, name: r['name'] as String, model: r['model'] as String, specification: r['specification'] as String, stock: r['stock'] as int, unitPrice: r['unit_price'] as int, branchId: r['branch_id'] as int)).toList();
    }
    try {
      final data = await _api.post('/get-branch-stock', {'branch_id': branchId});
      final list = (data['products'] as List<dynamic>?) ?? [];
      final products = list.map((e) => Product(id: e['id'] as int, name: e['name'] as String, model: e['model'] as String? ?? '', specification: e['spec'] as String? ?? '', stock: e['stock'] as int? ?? 0, unitPrice: e['unit_price'] as int? ?? 0, branchId: branchId)).toList();
      for (final p in products) {
        await db.insert('products', {'id': p.id, 'name': p.name, 'model': p.model, 'specification': p.specification, 'stock': p.stock, 'unit_price': p.unitPrice, 'branch_id': p.branchId});
      }
      return products;
    } catch (_) {
      return [];
    }
  }

  // --- Staff ---
  @override
  Future<void> addStaff(Staff staff) async {
    final db = await _sqlite.db;
    await db.insert('staff', {'id': staff.id, 'name': staff.name, 'phone': '', 'branch_id': staff.branchId});
  }

  @override
  Future<List<Staff>> getStaff(int branchId) async {
    final db = await _sqlite.db;
    final rows = await db.query('staff', where: 'branch_id = ?', whereArgs: [branchId]);
    return rows.map((r) => Staff(id: r['id'] as int, name: r['name'] as String, branchId: r['branch_id'] as int)).toList();
  }

  // --- Branch Costs ---
  @override
  Future<void> addBranchCost(BranchCost cost) async {
    final db = await _sqlite.db;
    await db.insert('branch_costs', {'id': cost.id, 'branch_id': cost.branchId, 'description': cost.title, 'amount': cost.amount, 'created_at': cost.createdAt.toIso8601String()});
  }

  @override
  Future<List<BranchCost>> getBranchCosts(int branchId) async {
    final db = await _sqlite.db;
    final rows = await db.query('branch_costs', where: 'branch_id = ?', whereArgs: [branchId]);
    return rows.map((r) => BranchCost(id: r['id'] as int, branchId: r['branch_id'] as int, title: r['description'] as String, amount: r['amount'] as int, createdAt: DateTime.parse(r['created_at'] as String))).toList();
  }

  // --- Sales ---
  @override
  Future<void> recordSale(Sale sale) async {
    final db = await _sqlite.db;
    await db.insert('sales', {'id': sale.id, 'product_id': sale.productId, 'product_name': sale.productName, 'salesperson': sale.salesperson, 'quantity': sale.quantity, 'unit_price': sale.unitPrice, 'total': sale.total, 'created_at': sale.createdAt.toIso8601String(), 'branch_id': sale.branchId});
    // update product stock if present
    final rows = await db.query('products', where: 'id = ?', whereArgs: [sale.productId]);
    if (rows.isNotEmpty) {
      final p = rows.first;
      final newStock = (p['stock'] as int) - sale.quantity;
      await db.update('products', {'stock': newStock}, where: 'id = ?', whereArgs: [sale.productId]);
    }
    try {
      await _api.post('/record-sale', {'product_id': sale.productId, 'quantity': sale.quantity});
    } catch (_) {}
  }

  @override
  Future<List<Sale>> getSales(int branchId) async {
    final db = await _sqlite.db;
    final rows = await db.query('sales', where: 'branch_id = ?', whereArgs: [branchId]);
    return rows.map((r) => Sale(id: r['id'] as int, productId: r['product_id'] as int, productName: r['product_name'] as String, salesperson: r['salesperson'] as String, quantity: r['quantity'] as int, unitPrice: r['unit_price'] as int, total: r['total'] as int, createdAt: DateTime.parse(r['created_at'] as String), branchId: r['branch_id'] as int)).toList();
  }

  // --- Reports ---
  @override
  Future<void> addReport(Report report) async {
    final db = await _sqlite.db;
    await db.insert('reports', {'id': report.id, 'branch_id': report.branchId, 'date': report.date, 'total_amount': report.totalAmount, 'total_units': report.totalUnits, 'total_products': report.totalProducts, 'total_cost': report.totalCost, 'is_deposited': report.isDeposited ? 1 : 0});
  }

  @override
  Future<List<Report>> getReports() async {
    final db = await _sqlite.db;
    final rows = await db.query('reports');
    return rows.map((r) => Report(id: r['id'] as int, branchId: r['branch_id'] as int, date: r['date'] as String, totalAmount: r['total_amount'] as int, totalUnits: r['total_units'] as int, totalProducts: r['total_products'] as int, totalCost: r['total_cost'] as int, isDeposited: (r['is_deposited'] as int) == 1)).toList();
  }

  @override
  Future<void> markReportDeposited(int reportId) async {
    final db = await _sqlite.db;
    await db.update('reports', {'is_deposited': 1}, where: 'id = ?', whereArgs: [reportId]);
  }
}
