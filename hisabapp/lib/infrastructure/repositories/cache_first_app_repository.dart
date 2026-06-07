import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/app_repository.dart';

class CacheFirstAppRepository implements AppRepository {
  final AppRepository _localRepository;
  final AppRepository _remoteRepository;

  CacheFirstAppRepository({
    required AppRepository localRepository,
    required AppRepository remoteRepository,
  })  : _localRepository = localRepository,
        _remoteRepository = remoteRepository;

  @override
  Future<void> addBranch(Branch branch) => _localRepository.addBranch(branch);

  @override
  Future<void> addProduct(Product product) => _localRepository.addProduct(product);

  @override
  Future<void> addStaff(Staff staff) => _localRepository.addStaff(staff);

  @override
  Future<void> addBranchCost(BranchCost cost) => _localRepository.addBranchCost(cost);

  @override
  Future<void> addReport(Report report) => _localRepository.addReport(report);

  @override
  Future<List<Branch>> getBranches() async {
    final cached = await _localRepository.getBranches();
    if (cached.isNotEmpty) return cached;

    try {
      final remote = await _remoteRepository.getBranches();
      for (final branch in remote) {
        await _localRepository.addBranch(branch);
      }
      return remote;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<List<String>> getProductAttributes() async {
    final cached = await _localRepository.getProductAttributes();
    if (cached.isNotEmpty) return cached;

    try {
      final remote = await _remoteRepository.getProductAttributes();
      await _localRepository.saveProductAttributes(remote);
      return remote;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<void> saveProductAttributes(List<String> attributes) =>
      _localRepository.saveProductAttributes(attributes);

  @override
  Future<void> deleteProduct(int productId) =>
      _localRepository.deleteProduct(productId);

  @override
  Future<void> deleteStaff(int staffId) =>
      _localRepository.deleteStaff(staffId);

  @override
  Future<void> deleteBranchCost(int costId) =>
      _localRepository.deleteBranchCost(costId);

  @override
  Future<List<Product>> getProducts(int branchId) async {
    final cached = await _localRepository.getProducts(branchId);
    if (cached.isNotEmpty) return cached;

    try {
      final remote = await _remoteRepository.getProducts(branchId);
      for (final product in remote) {
        await _localRepository.addProduct(product);
      }
      return remote;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<List<Staff>> getStaff(int branchId) async {
    final cached = await _localRepository.getStaff(branchId);
    if (cached.isNotEmpty) return cached;

    try {
      final remote = await _remoteRepository.getStaff(branchId);
      for (final staff in remote) {
        await _localRepository.addStaff(staff);
      }
      return remote;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<List<BranchCost>> getBranchCosts(int branchId) async {
    final cached = await _localRepository.getBranchCosts(branchId);
    if (cached.isNotEmpty) return cached;

    try {
      final remote = await _remoteRepository.getBranchCosts(branchId);
      for (final cost in remote) {
        await _localRepository.addBranchCost(cost);
      }
      return remote;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<List<Sale>> getSales(int branchId) async {
    final cached = await _localRepository.getSales(branchId);
    if (cached.isNotEmpty) return cached;

    try {
      final remote = await _remoteRepository.getSales(branchId);
      for (final sale in remote) {
        await _localRepository.recordSale(sale);
      }
      return remote;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<List<Report>> getReports() async {
    final cached = await _localRepository.getReports();
    if (cached.isNotEmpty) return cached;

    try {
      final remote = await _remoteRepository.getReports();
      for (final report in remote) {
        await _localRepository.addReport(report);
      }
      return remote;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<User?> login(String username, String password) async {
    final localUser = await _localRepository.login(username, password);
    if (localUser != null) return localUser;

    try {
      final remoteUser = await _remoteRepository.login(username, password);
      if (remoteUser != null) {
        await _localRepository.signUp(remoteUser);
      }
      return remoteUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markReportDeposited(int reportId) =>
      _localRepository.markReportDeposited(reportId);

  @override
  Future<void> recordSale(Sale sale) => _localRepository.recordSale(sale);

  @override
  Future<void> registerBusiness(String businessName, String businessType) =>
      _localRepository.registerBusiness(businessName, businessType);

  @override
  Future<void> signUp(User user) => _localRepository.signUp(user);
}
