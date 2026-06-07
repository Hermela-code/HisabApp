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
  Future<void> addBranch(Branch branch) => _api.addBranch(branch);

  @override
  Future<void> addProduct(Product product) => _api.addProduct(product);

  @override
  Future<void> deleteProduct(int productId) => _api.deleteProduct(productId);

  @override
  Future<void> deleteStaff(int staffId) => _api.deleteStaff(staffId);

  @override
  Future<void> addStaff(Staff staff) => _api.addStaff(staff);

  @override
  Future<void> addBranchCost(BranchCost cost) => _api.addBranchCost(cost);

  @override
  Future<void> deleteBranchCost(int costId) => _api.deleteBranchCost(costId);

  @override
  Future<void> addReport(Report report) => _api.generateSnapshot(report.branchId);

  @override
  Future<void> registerBusiness(String businessName, String businessType) =>
      _api.registerBusiness(businessName, businessType);

  @override
  Future<List<Branch>> getBranches() => _api.fetchBranches();

  @override
  Future<List<String>> getProductAttributes() => _api.fetchProductAttributes();

  @override
  Future<void> saveProductAttributes(List<String> attributes) =>
      _api.saveProductAttributes(attributes, 1);

  @override
  Future<void> recordSale(Sale sale) async {
    int staffId = 1;
    try {
      final staffList = await getStaff(sale.branchId);
      final match = staffList.firstWhere(
        (s) => s.name.toLowerCase().trim() == sale.salesperson.toLowerCase().trim(),
      );
      staffId = match.id;
    } catch (_) {
      try {
        final staffList = await getStaff(sale.branchId);
        if (staffList.isNotEmpty) {
          staffId = staffList.first.id;
        }
      } catch (_) {}
    }
    await _api.recordSale(sale, staffId, 1);
  }

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
  Future<void> markReportDeposited(int reportId) => _api.markReportDeposited(reportId);

  @override
  Future<void> signUp(User user) => _api.signUp(user);
}
