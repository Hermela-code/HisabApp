import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';

class RemoteAppApi {
  static const String defaultBaseUrl = 'http://localhost:8080';

  final String baseUrl;
  final http.Client _client;

  RemoteAppApi(this._client, {this.baseUrl = defaultBaseUrl});

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  void _validateResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw http.ClientException('Remote API error: ${response.statusCode} - ${response.body}', response.request?.url);
    }
  }

  Future<List<Branch>> fetchBranches() async {
    final response = await _client.get(_uri('/branches'));
    _validateResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => _branchFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<String>> fetchProductAttributes() async {
    final response = await _client.get(_uri('/product-attributes'));
    _validateResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) {
      if (item is String) return item;
      return item['name'] as String;
    }).toList();
  }

  Future<List<Product>> fetchProducts(int branchId) async {
    final path = branchId == 0 ? '/products' : '/branches/$branchId/products';
    final response = await _client.get(_uri(path));
    _validateResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => _productFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Staff>> fetchStaff(int branchId) async {
    final path = branchId == 0 ? '/staff' : '/branches/$branchId/staff';
    final response = await _client.get(_uri(path));
    _validateResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => _staffFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<BranchCost>> fetchBranchCosts(int branchId) async {
    final response = await _client.get(_uri('/branches/$branchId/costs'));
    _validateResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => _branchCostFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Sale>> fetchSales(int branchId) async {
    final response = await _client.get(_uri('/branches/$branchId/sales'));
    _validateResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => _saleFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Report>> fetchReports() async {
    final response = await _client.get(_uri('/reports'));
    _validateResponse(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => _reportFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<User?> login(String username, String password) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 401 || response.statusCode == 404) {
      return null;
    }
    _validateResponse(response);
    return _userFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Branch _branchFromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as int,
        name: json['name'] as String,
        companyId: json['company_id'] as int,
        location: json['location'] as String? ?? '',
        cashier: json['cashier'] as String? ?? '',
      );

  Product _productFromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        model: json['model'] as String,
        specification: json['specification'] as String,
        category: json['category'] as String? ?? ProductCategories.mobile,
        stock: json['stock'] as int,
        unitPrice: json['unit_price'] as int,
        costPrice: json['cost_price'] as int? ?? json['costPrice'] as int? ?? 0,
        branchId: json['branch_id'] as int,
      );

  Staff _staffFromJson(Map<String, dynamic> json) => Staff(
        id: json['id'] as int,
        name: json['name'] as String,
        branchId: json['branch_id'] as int,
      );

  BranchCost _branchCostFromJson(Map<String, dynamic> json) => BranchCost(
        id: json['id'] as int,
        branchId: json['branch_id'] as int,
        title: json['description'] as String,
        amount: json['amount'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Sale _saleFromJson(Map<String, dynamic> json) => Sale(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        productName: json['product_name'] as String,
        salesperson: json['salesperson'] as String,
        quantity: json['quantity'] as int,
        unitPrice: json['unit_price'] as int,
        total: json['total'] as int,
        costTotal: json['cost_total'] as int? ?? json['costTotal'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
        branchId: json['branch_id'] as int,
      );

  Report _reportFromJson(Map<String, dynamic> json) => Report(
        id: json['id'] as int,
        branchId: json['branch_id'] as int,
        date: json['date'] as String,
        totalAmount: json['total_amount'] as int,
        totalUnits: json['total_units'] as int,
        totalProducts: json['total_products'] as int,
        totalCost: json['total_cost'] as int,
        isDeposited: (json['is_deposited'] as int) == 1,
      );

  User _userFromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        password: json['password'] as String,
        role: json['role'] == 'cashier' ? UserRole.cashier : UserRole.owner,
        companyId: json['company_id'] as int,
        branchId: json['branch_id'] as int?,
      );

  Future<void> registerBusiness(String businessName, String businessType) async {
    final response = await _client.post(
      _uri('/register-business'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'business_name': businessName,
        'business_type': businessType,
      }),
    );
    _validateResponse(response);
  }

  Future<void> signUp(User user) async {
    final response = await _client.post(
      _uri('/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': user.id,
        'username': user.username,
        'password': user.password,
        'role': user.role == UserRole.cashier ? 'cashier' : 'owner',
        'company_id': user.companyId,
        'branch_id': user.branchId,
      }),
    );
    _validateResponse(response);
  }

  Future<void> addBranch(Branch branch) async {
    final response = await _client.post(
      _uri('/add-branch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': branch.id,
        'branch_id': branch.id,
        'company_id': branch.companyId,
        'branch_name': branch.name,
        'location': branch.location,
        'cashier_name': branch.cashier,
      }),
    );
    _validateResponse(response);
  }

  Future<void> addProduct(Product product) async {
    final response = await _client.post(
      _uri('/add-product'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': product.id,
        'product_id': product.id,
        'branch_id': product.branchId,
        'product_name': product.name,
        'brand': product.model,
        'category': product.category,
        'specification': product.specification,
        'selling_price': product.unitPrice,
        'cost_price': product.costPrice,
        'total_stock': product.stock,
        'low_stock_alert': 5,
        'high_stock_alert': 10,
      }),
    );
    _validateResponse(response);
  }

  Future<void> deleteProduct(int productId) async {
    final response = await _client.delete(
      _uri('/delete-product'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'product_id': productId}),
    );
    _validateResponse(response);
  }

  Future<void> addStaff(Staff staff) async {
    final response = await _client.post(
      _uri('/add-staff'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': staff.id,
        'staff_id': staff.id,
        'branch_id': staff.branchId,
        'name': staff.name,
        'phone_number': staff.phone,
        'role': 'Staff',
      }),
    );
    _validateResponse(response);
  }

  Future<void> deleteStaff(int staffId) async {
    final response = await _client.delete(
      _uri('/delete-staff'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'staff_id': staffId}),
    );
    _validateResponse(response);
  }

  Future<void> addBranchCost(BranchCost cost) async {
    final response = await _client.post(
      _uri('/add-branch-cost'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': cost.id,
        'cost_id': cost.id,
        'branch_id': cost.branchId,
        'description': cost.title,
        'amount': cost.amount,
        'expense_date': cost.createdAt.toIso8601String().split('T').first,
      }),
    );
    _validateResponse(response);
  }

  Future<void> deleteBranchCost(int costId) async {
    final response = await _client.delete(
      _uri('/delete-branch-cost'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cost_id': costId}),
    );
    _validateResponse(response);
  }

  Future<void> recordSale(Sale sale, int staffId, int userId) async {
    final response = await _client.post(
      _uri('/record-sale'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': sale.id,
        'sale_id': sale.id,
        'branch_id': sale.branchId,
        'user_id': userId,
        'staff_id': staffId,
        'total_amount': sale.total,
        'items': [
          {
            'product_id': sale.productId,
            'quantity': sale.quantity,
            'price': sale.unitPrice,
            'cost': sale.quantity > 0 ? (sale.costTotal ~/ sale.quantity) : 0,
          }
        ]
      }),
    );
    _validateResponse(response);
  }

  Future<void> generateSnapshot(int branchId) async {
    final response = await _client.post(
      _uri('/generate-daily-snapshot'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'branch_id': branchId}),
    );
    _validateResponse(response);
  }

  Future<void> markReportDeposited(int reportId) async {
    final response = await _client.patch(
      _uri('/mark-as-deposited?id=$reportId'),
    );
    _validateResponse(response);
  }

  Future<void> saveProductAttributes(List<String> attributes, int companyId) async {
    final response = await _client.post(
      _uri('/setup/define-attributes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_id': companyId,
        'attributes': attributes,
      }),
    );
    _validateResponse(response);
  }
}

