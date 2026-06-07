import 'package:http/http.dart' as http;

import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/app_repository.dart';
import '../remote/remote_app_api.dart';

class RemoteAppRepository implements AppRepository {
  final RemoteAppApi _api;

  RemoteAppRepository({required http.Client client, String baseUrl = RemoteAppApi.defaultBaseUrl})
      : _api = RemoteAppApi(client, baseUrl: baseUrl);

  @override
  Future<void> addBranch(Branch branch) => throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> addProduct(Product product) => throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> deleteProduct(int productId) =>
      throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> deleteStaff(int staffId) =>
      throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> addStaff(Staff staff) => throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> addBranchCost(BranchCost cost) => throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> deleteBranchCost(int costId) =>
      throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> addReport(Report report) => throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> registerBusiness(String businessName, String businessType) =>
      throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<List<Branch>> getBranches() => _api.fetchBranches();

  @override
  Future<List<String>> getProductAttributes() => _api.fetchProductAttributes();

  @override
  Future<void> saveProductAttributes(List<String> attributes) =>
      throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> recordSale(Sale sale) => throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<List<Product>> getProducts(int branchId) => _api.fetchProducts(branchId);

  @override
  Future<List<Staff>> getStaff(int branchId) => _api.fetchStaff(branchId);

  @override
  Future<List<BranchCost>> getBranchCosts(int branchId) => _api.fetchBranchCosts(branchId);

  @override
  Future<List<Sale>> getSales(int branchId) => _api.fetchSales(branchId);

  @override
  Future<List<Report>> getReports() => _api.fetchReports();

  @override
  Future<User?> login(String username, String password) => _api.login(username, password);

  @override
  Future<void> markReportDeposited(int reportId) =>
      throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');

  @override
  Future<void> signUp(User user) => throw UnimplementedError('Remote write operations are not supported by RemoteAppRepository');
}
