import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabapp/application/providers/cashier_data_provider.dart';
import 'package:hisabapp/application/providers/session_provider.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/domain/entities/branch.dart';
import 'package:hisabapp/domain/entities/branch_cost.dart';
import 'package:hisabapp/domain/entities/product.dart';
import 'package:hisabapp/domain/entities/report.dart';
import 'package:hisabapp/domain/entities/sale.dart';
import 'package:hisabapp/domain/entities/staff.dart';
import 'package:hisabapp/domain/entities/user.dart';
import 'package:hisabapp/domain/repositories/app_repository.dart';

class FakeAppRepository implements AppRepository {
  final List<Branch> branches = [];
  final List<Product> products = [];
  final List<Staff> staff = [];
  final List<BranchCost> costs = [];
  final List<Sale> sales = [];
  final List<Report> reports = [];
  final List<String> attributes = [];
  User? user;

  @override
  Future<void> registerBusiness(String businessName, String businessType) async {}

  @override
  Future<void> signUp(User user) async {
    this.user = user;
  }

  @override
  Future<User?> login(String username, String password) async => user;

  @override
  Future<void> addBranch(Branch branch) async {
    branches.add(branch);
  }

  @override
  Future<List<Branch>> getBranches() async => branches;

  @override
  Future<List<String>> getProductAttributes() async => attributes;

  @override
  Future<void> saveProductAttributes(List<String> attributes) async {
    this.attributes.clear();
    this.attributes.addAll(attributes);
  }

  @override
  Future<void> addProduct(Product product) async {
    products.removeWhere((p) => p.id == product.id);
    products.add(product);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    products.removeWhere((p) => p.id == productId);
  }

  @override
  Future<List<Product>> getProducts(int branchId) async {
    return products.where((p) => p.branchId == branchId).toList();
  }

  @override
  Future<void> addStaff(Staff staffMember) async {
    staff.removeWhere((s) => s.id == staffMember.id);
    staff.add(staffMember);
  }

  @override
  Future<void> deleteStaff(int staffId) async {
    staff.removeWhere((s) => s.id == staffId);
  }

  @override
  Future<List<Staff>> getStaff(int branchId) async {
    return staff.where((s) => s.branchId == branchId).toList();
  }

  @override
  Future<void> addBranchCost(BranchCost cost) async {
    costs.removeWhere((c) => c.id == cost.id);
    costs.add(cost);
  }

  @override
  Future<void> deleteBranchCost(int costId) async {
    costs.removeWhere((c) => c.id == costId);
  }

  @override
  Future<List<BranchCost>> getBranchCosts(int branchId) async {
    return costs.where((c) => c.branchId == branchId).toList();
  }

  @override
  Future<void> recordSale(Sale sale) async {
    sales.add(sale);
    // update product stock in fake repo
    final idx = products.indexWhere((p) => p.name == sale.productName);
    if (idx != -1) {
      final p = products[idx];
      products[idx] = p.copyWith(stock: p.stock - sale.quantity);
    }
  }

  @override
  Future<List<Sale>> getSales(int branchId) async {
    // Note: Sale entity does not have branchId direct, but we return all sales for simplicity
    return sales;
  }

  @override
  Future<void> addReport(Report report) async {
    reports.add(report);
  }

  @override
  Future<List<Report>> getReports() async => reports;

  @override
  Future<void> markReportDeposited(int reportId) async {}
}

void main() {
  group('CashierDataProvider Tests', () {
    late FakeAppRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeAppRepository();
      container = ProviderContainer(
        overrides: [
          appRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    const mockCashier = User(
      id: 1,
      username: 'test_cashier',
      password: 'x',
      role: UserRole.cashier,
      companyId: 1,
      branchId: 1,
    );

    test('initial state has empty data', () {
      final state = container.read(cashierDataProvider);
      expect(state.products, isEmpty);
      expect(state.sales, isEmpty);
      expect(state.costs, isEmpty);
      expect(state.staff, isEmpty);
    });

    test('reload fetches correct cashier data when user is cashier', () async {
      // Add data to repo
      fakeRepo.products.add(Product(id: 1, name: 'Phone', model: 'A', specification: '128', category: '', stock: 10, unitPrice: 100, branchId: 1));
      fakeRepo.staff.add(Staff(id: 1, name: 'John', phone: '123', branchId: 1));
      fakeRepo.costs.add(BranchCost(id: 1, branchId: 1, title: 'Rent', amount: 50, createdAt: DateTime.now()));

      // Login
      container.read(sessionProvider.notifier).setUser(mockCashier);
      // Wait for build to complete reload
      await container.read(cashierDataProvider.notifier).reload();

      final state = container.read(cashierDataProvider);
      expect(state.products, hasLength(1));
      expect(state.products.first.name, equals('Phone'));
      expect(state.staff, hasLength(1));
      expect(state.staff.first.name, equals('John'));
      expect(state.costs, hasLength(1));
      expect(state.costs.first.description, equals('Rent'));
    });

    test('addProduct adds to state and repository', () async {
      container.read(sessionProvider.notifier).setUser(mockCashier);

      await container.read(cashierDataProvider.notifier).addProduct(
        name: 'Tablet',
        model: 'TabS',
        specification: '64GB',
        sellingPrice: 300,
        totalStock: 5,
        remainingStock: 5,
      );

      final state = container.read(cashierDataProvider);
      expect(state.products, hasLength(1));
      expect(state.products.first.name, equals('Tablet'));
      expect(fakeRepo.products, hasLength(1));
      expect(fakeRepo.products.first.name, equals('Tablet'));
    });

    test('addStockToProduct updates product stock', () async {
      container.read(sessionProvider.notifier).setUser(mockCashier);
      await container.read(cashierDataProvider.notifier).addProduct(
        name: 'Tablet',
        model: 'TabS',
        specification: '64GB',
        sellingPrice: 300,
        totalStock: 5,
        remainingStock: 5,
      );

      final productId = container.read(cashierDataProvider).products.first.id;

      await container.read(cashierDataProvider.notifier).addStockToProduct(productId, 3);

      final state = container.read(cashierDataProvider);
      expect(state.products.first.stock, equals(8));
      expect(fakeRepo.products.first.stock, equals(8));
    });

    test('removeProduct deletes from state and repo', () async {
      container.read(sessionProvider.notifier).setUser(mockCashier);
      await container.read(cashierDataProvider.notifier).addProduct(
        name: 'Tablet',
        model: 'TabS',
        specification: '64GB',
        sellingPrice: 300,
        totalStock: 5,
        remainingStock: 5,
      );

      final productId = container.read(cashierDataProvider).products.first.id;

      await container.read(cashierDataProvider.notifier).removeProduct(productId);

      expect(container.read(cashierDataProvider).products, isEmpty);
      expect(fakeRepo.products, isEmpty);
    });

    test('updateProduct updates details in state and repo', () async {
      container.read(sessionProvider.notifier).setUser(mockCashier);
      await container.read(cashierDataProvider.notifier).addProduct(
        name: 'Tablet',
        model: 'TabS',
        specification: '64GB',
        sellingPrice: 300,
        totalStock: 5,
        remainingStock: 5,
      );

      final productId = container.read(cashierDataProvider).products.first.id;

      await container.read(cashierDataProvider.notifier).updateProduct(
        productId: productId,
        name: 'Updated Tablet',
        model: 'TabS2',
        specification: '128GB',
        sellingPrice: 350,
        stock: 12,
      );

      final product = container.read(cashierDataProvider).products.first;
      expect(product.name, equals('Updated Tablet'));
      expect(product.unitPrice, equals(350));
      expect(product.stock, equals(12));
    });

    test('addCost and removeCost manages cost records', () async {
      container.read(sessionProvider.notifier).setUser(mockCashier);

      await container.read(cashierDataProvider.notifier).addCost(description: 'Internet', amount: 30);
      
      var state = container.read(cashierDataProvider);
      expect(state.costs, hasLength(1));
      expect(state.costs.first.description, equals('Internet'));
      expect(state.costs.first.amount, equals(30));

      final costId = state.costs.first.id;
      await container.read(cashierDataProvider.notifier).removeCost(costId);

      state = container.read(cashierDataProvider);
      expect(state.costs, isEmpty);
    });

    test('addStaff and removeStaff manages staff members', () async {
      container.read(sessionProvider.notifier).setUser(mockCashier);

      await container.read(cashierDataProvider.notifier).addStaff(name: 'Alice', phone: '9999');
      
      var state = container.read(cashierDataProvider);
      expect(state.staff, hasLength(1));
      expect(state.staff.first.name, equals('Alice'));

      final staffId = state.staff.first.id;
      await container.read(cashierDataProvider.notifier).removeStaff(staffId);

      state = container.read(cashierDataProvider);
      expect(state.staff, isEmpty);
    });

    test('recordSale updates sales list and decrements stock', () async {
      container.read(sessionProvider.notifier).setUser(mockCashier);
      await container.read(cashierDataProvider.notifier).addProduct(
        name: 'Phone',
        model: 'A',
        specification: '128',
        sellingPrice: 100,
        totalStock: 10,
        remainingStock: 10,
      );

      final sale = Sale(
        id: 1,
        productId: 1,
        productName: 'Phone',
        salesperson: 'Alice',
        quantity: 2,
        total: 200,
        unitPrice: 100,
        createdAt: DateTime.now(),
        branchId: 1,
      );

      await container.read(cashierDataProvider.notifier).recordSale(sale);

      final state = container.read(cashierDataProvider);
      expect(state.sales, hasLength(1));
      expect(state.sales.first.productName, equals('Phone'));
      expect(state.sales.first.quantity, equals(2));
      // stock decremented from 10 to 8
      expect(state.products.first.stock, equals(8));
    });

    test('cashierDailyMetricsProvider calculates correct financials for date', () async {
      container.read(sessionProvider.notifier).setUser(mockCashier);
      await container.read(cashierDataProvider.notifier).addProduct(
        name: 'ItemA',
        model: 'X',
        specification: '1',
        sellingPrice: 50,
        totalStock: 20,
        remainingStock: 20,
      );

      final todayStr = DateTime.now().toIso8601String().split('T').first;

      // add cost
      await container.read(cashierDataProvider.notifier).addCost(description: 'Snacks', amount: 15, date: todayStr);

      // add sale
      final sale = Sale(
        id: 1,
        productId: 1,
        productName: 'ItemA',
        salesperson: 'Bob',
        quantity: 3,
        total: 150,
        unitPrice: 50,
        createdAt: DateTime.now(),
        branchId: 1,
      );
      await container.read(cashierDataProvider.notifier).recordSale(sale);

      final metrics = container.read(cashierDailyMetricsProvider(todayStr));

      expect(metrics.income, equals(150));
      expect(metrics.costs, equals(15));
      expect(metrics.netProfit, equals(135));
      expect(metrics.transactions, equals(1));
      expect(metrics.units, equals(3));
    });
  });
}
