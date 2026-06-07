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
  Future<void> addBranch(Branch branch) async {
    await _localRepository.addBranch(branch);
    try {
      await _remoteRepository.addBranch(branch);
    } catch (e) {
      print('Failed to sync addBranch remotely: $e');
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    await _localRepository.addProduct(product);
    try {
      await _remoteRepository.addProduct(product);
    } catch (e) {
      print('Failed to sync addProduct remotely: $e');
    }
  }

  @override
  Future<void> addStaff(Staff staff) async {
    await _localRepository.addStaff(staff);
    try {
      await _remoteRepository.addStaff(staff);
    } catch (e) {
      print('Failed to sync addStaff remotely: $e');
    }
  }

  @override
  Future<void> addBranchCost(BranchCost cost) async {
    await _localRepository.addBranchCost(cost);
    try {
      await _remoteRepository.addBranchCost(cost);
    } catch (e) {
      print('Failed to sync addBranchCost remotely: $e');
    }
  }

  @override
  Future<void> addReport(Report report) async {
    await _localRepository.addReport(report);
    try {
      await _remoteRepository.addReport(report);
    } catch (e) {
      print('Failed to sync addReport remotely: $e');
    }
  }

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
  Future<void> saveProductAttributes(List<String> attributes) async {
    await _localRepository.saveProductAttributes(attributes);
    try {
      await _remoteRepository.saveProductAttributes(attributes);
    } catch (e) {
      print('Failed to sync saveProductAttributes remotely: $e');
    }
  }

  @override
  Future<void> deleteProduct(int productId) async {
    await _localRepository.deleteProduct(productId);
    try {
      await _remoteRepository.deleteProduct(productId);
    } catch (e) {
      print('Failed to sync deleteProduct remotely: $e');
    }
  }

  @override
  Future<void> deleteStaff(int staffId) async {
    await _localRepository.deleteStaff(staffId);
    try {
      await _remoteRepository.deleteStaff(staffId);
    } catch (e) {
      print('Failed to sync deleteStaff remotely: $e');
    }
  }

  @override
  Future<void> deleteBranchCost(int costId) async {
    await _localRepository.deleteBranchCost(costId);
    try {
      await _remoteRepository.deleteBranchCost(costId);
    } catch (e) {
      print('Failed to sync deleteBranchCost remotely: $e');
    }
  }

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
  Future<void> markReportDeposited(int reportId) async {
    await _localRepository.markReportDeposited(reportId);
    try {
      await _remoteRepository.markReportDeposited(reportId);
    } catch (e) {
      print('Failed to sync markReportDeposited remotely: $e');
    }
  }

  @override
  Future<void> recordSale(Sale sale) async {
    await _localRepository.recordSale(sale);
    try {
      await _remoteRepository.recordSale(sale);
    } catch (e) {
      print('Failed to sync recordSale remotely: $e');
    }
  }

  @override
  Future<void> registerBusiness(String businessName, String businessType) async {
    await _localRepository.registerBusiness(businessName, businessType);
    try {
      await _remoteRepository.registerBusiness(businessName, businessType);
    } catch (e) {
      print('Failed to sync registerBusiness remotely: $e');
    }
  }

  @override
  Future<void> signUp(User user) async {
    await _localRepository.signUp(user);
    try {
      await _remoteRepository.signUp(user);
    } catch (e) {
      print('Failed to sync signUp remotely: $e');
    }
  }
}
