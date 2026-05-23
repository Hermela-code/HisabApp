import 'package:flutter_test/flutter_test.dart';
import 'package:hisabapp/domain/entities/branch.dart';
import 'package:hisabapp/domain/entities/branch_cost.dart';
import 'package:hisabapp/domain/entities/product.dart';
import 'package:hisabapp/domain/entities/report.dart';
import 'package:hisabapp/domain/entities/sale.dart';
import 'package:hisabapp/domain/entities/staff.dart';
import 'package:hisabapp/domain/entities/user.dart';
import 'package:hisabapp/domain/repositories/app_repository.dart';
import 'package:hisabapp/infrastructure/repositories/cache_first_app_repository.dart';

class _FakeLocalRepository implements AppRepository {
  final List<Branch> branches = [];
  final List<Product> products = [];
  User? user;

  @override
  Future<void> addBranch(Branch branch) async => branches.add(branch);

  @override
  Future<void> addProduct(Product product) async => products.add(product);

  @override
  Future<void> deleteProduct(int productId) async {
    products.removeWhere((p) => p.id == productId);
  }

  @override
  Future<List<Branch>> getBranches() async => List.from(branches);

  @override
  Future<List<Product>> getProducts(int branchId) async =>
      products.where((p) => p.branchId == branchId).toList();

  @override
  Future<User?> login(String username, String password) async => user;

  @override
  Future<void> signUp(User user) async => this.user = user;

  @override
  Future<void> addStaff(Staff staff) async {}

  @override
  Future<void> deleteStaff(int staffId) async {}

  @override
  Future<List<Staff>> getStaff(int branchId) async => [];

  @override
  Future<void> addBranchCost(BranchCost cost) async {}

  @override
  Future<void> deleteBranchCost(int costId) async {}

  @override
  Future<List<BranchCost>> getBranchCosts(int branchId) async => [];

  @override
  Future<void> recordSale(Sale sale) async {}

  @override
  Future<List<Sale>> getSales(int branchId) async => [];

  @override
  Future<void> addReport(Report report) async {}

  @override
  Future<List<Report>> getReports() async => [];

  @override
  Future<void> registerBusiness(String businessName, String businessType) async {}

  @override
  Future<void> markReportDeposited(int reportId) async {}

  @override
  Future<List<String>> getProductAttributes() async => [];

  @override
  Future<void> saveProductAttributes(List<String> attributes) async {}
}

class _FakeRemoteRepository implements AppRepository {
  final List<Branch> branches;
  final List<Product> products;
  final User? user;
  bool branchesCalled = false;
  bool productsCalled = false;
  bool loginCalled = false;

  _FakeRemoteRepository({
    this.branches = const [],
    this.products = const [],
    this.user,
  });

  @override
  Future<List<Branch>> getBranches() async {
    branchesCalled = true;
    return branches;
  }

  @override
  Future<List<Product>> getProducts(int branchId) async {
    productsCalled = true;
    return products.where((p) => p.branchId == branchId).toList();
  }

  @override
  Future<User?> login(String username, String password) async {
    loginCalled = true;
    return user;
  }

  @override
  Future<void> addBranch(Branch branch) async {}

  @override
  Future<void> addProduct(Product product) async {}

  @override
  Future<void> deleteProduct(int productId) async {}

  @override
  Future<void> addStaff(Staff staff) async {}

  @override
  Future<void> deleteStaff(int staffId) async {}

  @override
  Future<List<Staff>> getStaff(int branchId) async => [];

  @override
  Future<void> addBranchCost(BranchCost cost) async {}

  @override
  Future<void> deleteBranchCost(int costId) async {}

  @override
  Future<List<BranchCost>> getBranchCosts(int branchId) async => [];

  @override
  Future<void> recordSale(Sale sale) async {}

  @override
  Future<List<Sale>> getSales(int branchId) async => [];

  @override
  Future<void> addReport(Report report) async {}

  @override
  Future<List<Report>> getReports() async => [];

  @override
  Future<void> registerBusiness(String businessName, String businessType) async {}

  @override
  Future<void> markReportDeposited(int reportId) async {}

  @override
  Future<void> signUp(User user) async {}

  @override
  Future<List<String>> getProductAttributes() async => [];

  @override
  Future<void> saveProductAttributes(List<String> attributes) async {}
}

void main() {
  group('CacheFirstAppRepository', () {
    test('returns cached branches without calling remote', () async {
      final local = _FakeLocalRepository()
        ..branches.add(Branch(id: 1, name: 'Main', companyId: 1, location: '', cashier: ''));
      final remote = _FakeRemoteRepository(
        branches: [Branch(id: 99, name: 'Remote', companyId: 1, location: '', cashier: '')],
      );
      final repo = CacheFirstAppRepository(
        localRepository: local,
        remoteRepository: remote,
      );

      final result = await repo.getBranches();

      expect(result, hasLength(1));
      expect(result.first.name, 'Main');
      expect(remote.branchesCalled, isFalse);
    });

    test('fetches remote when local empty and caches result', () async {
      final local = _FakeLocalRepository();
      final remote = _FakeRemoteRepository(
        branches: [Branch(id: 2, name: 'Remote Branch', companyId: 1, location: '', cashier: '')],
      );
      final repo = CacheFirstAppRepository(
        localRepository: local,
        remoteRepository: remote,
      );

      final result = await repo.getBranches();

      expect(result, hasLength(1));
      expect(result.first.name, 'Remote Branch');
      expect(remote.branchesCalled, isTrue);
      expect(local.branches, hasLength(1));
    });

    test('returns empty list when local empty and remote fails', () async {
      final local = _FakeLocalRepository();
      final remote = _ThrowingRemoteRepository();
      final repo = CacheFirstAppRepository(
        localRepository: local,
        remoteRepository: remote,
      );

      final result = await repo.getProducts(1);

      expect(result, isEmpty);
    });

    test('login prefers local user over remote', () async {
      final local = _FakeLocalRepository()
        ..user = const User(
          id: 1,
          username: 'local',
          password: 'x',
          role: UserRole.owner,
          companyId: 1,
        );
      final remote = _FakeRemoteRepository(
        user: const User(
          id: 2,
          username: 'remote',
          password: 'x',
          role: UserRole.cashier,
          companyId: 1,
          branchId: 1,
        ),
      );
      final repo = CacheFirstAppRepository(
        localRepository: local,
        remoteRepository: remote,
      );

      final user = await repo.login('local', 'x');

      expect(user?.username, 'local');
      expect(remote.loginCalled, isFalse);
    });

    test('writes go to local repository only', () async {
      final local = _FakeLocalRepository();
      final remote = _FakeRemoteRepository();
      final repo = CacheFirstAppRepository(
        localRepository: local,
        remoteRepository: remote,
      );

      await repo.addProduct(Product(
        id: 1,
        name: 'Phone',
        model: 'X',
        specification: '64GB',
        stock: 5,
        unitPrice: 100,
        branchId: 1,
      ));

      expect(local.products, hasLength(1));
      expect(remote.productsCalled, isFalse);
    });
  });
}

class _ThrowingRemoteRepository extends _FakeRemoteRepository {
  @override
  Future<List<Product>> getProducts(int branchId) async {
    throw Exception('network down');
  }
}
