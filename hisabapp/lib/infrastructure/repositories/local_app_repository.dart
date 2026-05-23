import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/app_repository.dart';
import '../data_sources/in_memory_data_store.dart';

class LocalAppRepository implements AppRepository {
  final InMemoryDataStore _dataStore;

  LocalAppRepository(this._dataStore);

  @override
  Future<void> addBranch(Branch branch) async {
    _dataStore.branches.add(branch);
  }

  @override
  Future<void> addProduct(Product product) async {
    _dataStore.products.removeWhere((p) => p.id == product.id);
    _dataStore.products.add(product);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    _dataStore.products.removeWhere((p) => p.id == productId);
  }

  @override
  Future<void> addStaff(Staff staff) async {
    _dataStore.staff.removeWhere((s) => s.id == staff.id);
    _dataStore.staff.add(staff);
  }

  @override
  Future<void> deleteStaff(int staffId) async {
    _dataStore.staff.removeWhere((s) => s.id == staffId);
  }

  @override
  Future<void> addBranchCost(BranchCost cost) async {
    _dataStore.branchCosts.removeWhere((c) => c.id == cost.id);
    _dataStore.branchCosts.add(cost);
  }

  @override
  Future<void> deleteBranchCost(int costId) async {
    _dataStore.branchCosts.removeWhere((c) => c.id == costId);
  }

  @override
  Future<void> addReport(Report report) async {
    _dataStore.reports.add(report);
  }

  @override
  Future<List<Branch>> getBranches() async {
    return List.unmodifiable(_dataStore.branches);
  }

  @override
  Future<List<String>> getProductAttributes() async {
    return List.unmodifiable(_dataStore.productAttributes);
  }

  @override
  Future<void> saveProductAttributes(List<String> attributes) async {
    _dataStore.productAttributes
      ..clear()
      ..addAll(attributes.map((a) => a.trim()).where((a) => a.isNotEmpty));
  }

  @override
  Future<List<Product>> getProducts(int branchId) async {
    if (branchId == 0) {
      return List.unmodifiable(_dataStore.products);
    }
    return _dataStore.products.where((product) => product.branchId == branchId).toList();
  }

  @override
  Future<List<Staff>> getStaff(int branchId) async {
    if (branchId == 0) {
      return List.unmodifiable(_dataStore.staff);
    }
    return _dataStore.staff.where((staff) => staff.branchId == branchId).toList();
  }

  @override
  Future<List<BranchCost>> getBranchCosts(int branchId) async {
    return _dataStore.branchCosts.where((cost) => cost.branchId == branchId).toList();
  }

  @override
  Future<List<Sale>> getSales(int branchId) async {
    return _dataStore.sales.where((sale) => sale.branchId == branchId).toList();
  }

  @override
  Future<List<Report>> getReports() async {
    return List.unmodifiable(_dataStore.reports);
  }

  @override
  Future<User?> login(String username, String password) async {
    try {
      return _dataStore.users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markReportDeposited(int reportId) async {
    final index = _dataStore.reports.indexWhere((report) => report.id == reportId);
    if (index != -1) {
      final report = _dataStore.reports[index];
      _dataStore.reports[index] = Report(
        id: report.id,
        branchId: report.branchId,
        date: report.date,
        totalAmount: report.totalAmount,
        totalUnits: report.totalUnits,
        totalProducts: report.totalProducts,
        totalCost: report.totalCost,
        isDeposited: true,
      );
    }
  }

  @override
  Future<void> registerBusiness(String businessName, String businessType) async {
    // In-memory store does not persist business details separately.
    // This method exists to satisfy the domain repository interface.
  }

  @override
  Future<void> recordSale(Sale sale) async {
    _dataStore.sales.removeWhere((s) => s.id == sale.id);
    _dataStore.sales.add(sale);
    final index = _dataStore.products.indexWhere((product) => product.id == sale.productId);
    if (index != -1) {
      final existing = _dataStore.products[index];
      _dataStore.products[index] = existing.copyWith(stock: existing.stock - sale.quantity);
    }
  }

  @override
  Future<void> signUp(User user) async {
    _dataStore.users.add(user);
  }
}
