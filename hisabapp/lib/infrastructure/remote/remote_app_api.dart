import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';

class RemoteAppApi {
  static const String defaultBaseUrl = 'http://localhost:8000';

  final String baseUrl;
  final http.Client _client;
  String? _token;

  RemoteAppApi(this._client, {this.baseUrl = defaultBaseUrl});

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('auth_token') ?? _token ?? '';

    if (token.isEmpty) {
      print('🚨 WARNING: Token is empty or null in SharedPreferences!');
    } else {
      print('✅ INJECTING TOKEN: $token');
    }

    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw http.ClientException('Remote API error: ${response.statusCode} - ${response.body}', response.request?.url);
    }
  }

  Future<List<Branch>> fetchBranches() async {
    final response = await _client.post(
      _uri('/branch.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'get_branches'}),
    );
    _validateResponse(response);
    final data = jsonDecode(response.body);
    final list = data is Map ? data['branches'] as List<dynamic> : data as List<dynamic>;
    return list.map((item) => _branchFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<String>> fetchProductAttributes() async {
    final response = await _client.post(
      _uri('/products.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'get_attributes'}),
    );
    _validateResponse(response);
    final data = jsonDecode(response.body);
    final list = data is Map ? (data['attributes'] ?? []) as List<dynamic> : data as List<dynamic>;
    return list.map((item) {
      if (item is String) return item;
      return item['name'] as String;
    }).toList();
  }

  Future<List<Product>> fetchProducts(int branchId) async {
    final response = await _client.post(
      _uri('/products.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'get_products', 'branch_id': branchId}),
    );
    _validateResponse(response);
    final data = jsonDecode(response.body);
    final list = data is Map ? data['products'] as List<dynamic> : data as List<dynamic>;
    return list.map((item) => _productFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Staff>> fetchStaff(int branchId) async {
    final response = await _client.post(
      _uri('/staff.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'get_staff', 'branch_id': branchId}),
    );
    _validateResponse(response);
    final data = jsonDecode(response.body);
    final list = data is Map ? data['staff'] ?? data['data'] ?? [] as List<dynamic> : data as List<dynamic>;
    return list.map((item) => _staffFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<BranchCost>> fetchBranchCosts(int branchId) async {
    final response = await _client.post(
      _uri('/branch.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'get_branch_costs', 'branch_id': branchId}),
    );
    _validateResponse(response);
    final data = jsonDecode(response.body);
    final list = data is Map ? data['costs'] ?? data['data'] ?? [] as List<dynamic> : data as List<dynamic>;
    return list.map((item) => _branchCostFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Sale>> fetchSales(int branchId) async {
    final response = await _client.get(
      _uri('/sales.php?action=get_sales&branch_id=$branchId'),
      headers: await _getHeaders(),
    );
    _validateResponse(response);
    final data = jsonDecode(response.body);
    final list = data is Map ? data['data'] as List<dynamic> : data as List<dynamic>;
    return list.map((item) => _saleFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Report>> fetchReports() async {
    final response = await _client.get(
      _uri('/sales.php?action=get_reports'),
      headers: await _getHeaders(),
    );
    _validateResponse(response);
    final data = jsonDecode(response.body);
    final list = data is Map ? data['data'] as List<dynamic> : data as List<dynamic>;
    return list.map((item) => _reportFromJson(item as Map<String, dynamic>)).toList();
  }

  Future<User?> login(String username, String password) async {
    final response = await _client.post(
      _uri('/auth.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'login', 'username': username, 'password': password}),
    );

    if (response.statusCode == 401 || response.statusCode == 404) {
      return null;
    }
    _validateResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _token = data['token'] as String?;
    if (_token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('auth_token', _token!);
    }
    return _userFromJson(data);
  }

  Branch _branchFromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as int,
        name: json['name'] ?? json['branch_name'] as String? ?? '',
        companyId: json['company_id'] as int,
        location: json['location'] as String? ?? '',
        cashier: json['cashier_name'] ?? json['cashier'] as String? ?? '',
      );

  Product _productFromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        model: json['brand'] ?? json['model'] as String? ?? '',
        specification: json['specification'] as String? ?? '',
        category: json['category'] as String? ?? ProductCategories.mobile,
        stock: json['current_stock'] ?? json['stock'] ?? json['units'] as int? ?? 0,
        unitPrice: json['selling_price'] ?? json['unit_price'] as int? ?? 0,
        costPrice: json['cost_price'] as int? ?? json['costPrice'] as int? ?? 0,
        branchId: json['branch_id'] as int? ?? 0,
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
        unitPrice: (json['unit_price'] as num).toInt(),
        total: (json['total'] as num).toInt(),
        costTotal: json['cost_total'] != null ? (json['cost_total'] as num).toInt() : (json['costTotal'] != null ? (json['costTotal'] as num).toInt() : 0),
        createdAt: DateTime.parse(json['created_at'] as String),
        branchId: json['branch_id'] as int,
      );

  Report _reportFromJson(Map<String, dynamic> json) => Report(
        id: json['id'] as int,
        branchId: json['branch_id'] as int,
        date: json['date'] ?? json['report_date'] as String? ?? '',
        totalAmount: json['total_amount'] != null ? (json['total_amount'] as num).toInt() : 0,
        totalUnits: json['total_units'] != null ? (json['total_units'] as num).toInt() : 0,
        totalProducts: json['total_products'] != null ? (json['total_products'] as num).toInt() : 0,
        totalCost: json['total_cost'] != null ? (json['total_cost'] as num).toInt() : 0,
        isDeposited: (json['is_deposited'] as int? ?? 0) == 1,
      );

  User _userFromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? 0 as int,
        username: json['name'] ?? json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
        role: json['role'] == 'Cashier' || json['role'] == 'cashier' ? UserRole.cashier : UserRole.owner,
        companyId: json['company_id'] as int? ?? 0,
        branchId: json['branch_id'] as int?,
      );

  Future<void> registerBusiness(String businessName, String businessType) async {
    final response = await _client.post(
      _uri('/auth.php'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'action': 'register_business',
        'business_name': businessName,
        'business_type': businessType,
      }),
    );
    _validateResponse(response);
  }

  Future<void> signUp(User user) async {
    final response = await _client.post(
      _uri('/auth.php'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'action': 'signup',
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
      _uri('/branch.php'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'action': 'create_branch',
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
      _uri('/products.php'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'action': 'create_product',
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
    final response = await _client.post(
      _uri('/products.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'delete_product', 'product_id': productId}),
    );
    _validateResponse(response);
  }

  Future<void> addStaff(Staff staff) async {
    final response = await _client.post(
      _uri('/staff.php'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'action': 'create_cashier',
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
    final response = await _client.post(
      _uri('/staff.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'delete_staff', 'staff_id': staffId}),
    );
    _validateResponse(response);
  }

  Future<void> addBranchCost(BranchCost cost) async {
    final response = await _client.post(
      _uri('/branch.php'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'action': 'add_branch_cost',
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
    final response = await _client.post(
      _uri('/branch.php'),
      headers: await _getHeaders(),
      body: jsonEncode({'action': 'delete_branch_cost', 'cost_id': costId}),
    );
    _validateResponse(response);
  }

  Future<void> recordSale(Sale sale, int staffId, int userId) async {
    final response = await _client.post(
      _uri('/sales.php?action=sync_sales'),
      headers: await _getHeaders(),
      body: jsonEncode([
        {
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
        }
      ]),
    );
    _validateResponse(response);
  }

  Future<void> generateSnapshot(int branchId) async {
    final response = await _client.post(
      _uri('/sales.php?action=generate_daily_snapshot'),
      headers: await _getHeaders(),
      body: jsonEncode({'branch_id': branchId}),
    );
    _validateResponse(response);
  }

  Future<void> markReportDeposited(int reportId) async {
    final response = await _client.post(
      _uri('/sales.php?action=mark_as_deposited'),
      headers: await _getHeaders(),
      body: jsonEncode({'id': reportId}),
    );
    _validateResponse(response);
  }

  Future<void> saveProductAttributes(List<String> attributes, int companyId) async {
    final response = await _client.post(
      _uri('/products.php'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'action': 'define_attributes',
        'company_id': companyId,
        'attributes': attributes,
      }),
    );
    _validateResponse(response);
  }
}
