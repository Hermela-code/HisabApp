import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../features/owner/branch_finance.dart';
import '../di.dart';
import '../models/daily_report.dart';
import 'session_provider.dart';

class CashierCostRecord {
  final int id;
  final String description;
  final String date;
  final int amount;

  const CashierCostRecord({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
  });

  static CashierCostRecord fromBranchCost(BranchCost cost) {
    return CashierCostRecord(
      id: cost.id,
      description: cost.title,
      date: cost.createdAt.toIso8601String().split('T').first,
      amount: cost.amount,
    );
  }
}

class CashierStaffMember {
  final int id;
  final String name;
  final String phone;
  final int branchId;

  const CashierStaffMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.branchId,
  });

  static CashierStaffMember fromStaff(Staff staff) {
    return CashierStaffMember(
      id: staff.id,
      name: staff.name,
      phone: staff.phone,
      branchId: staff.branchId,
    );
  }
}

class StaffPerformanceInfo {
  final CashierStaffMember member;
  final int totalUnits;
  final List<String> breakdown;

  const StaffPerformanceInfo({
    required this.member,
    required this.totalUnits,
    required this.breakdown,
  });
}

class CashierSaleRecord {
  final String date;
  final String productName;
  final String salesperson;
  final int quantity;
  final int total;
  final int unitPrice;

  const CashierSaleRecord({
    required this.date,
    required this.productName,
    required this.salesperson,
    required this.quantity,
    required this.total,
    required this.unitPrice,
  });

  factory CashierSaleRecord.fromSale(Sale sale) {
    return CashierSaleRecord(
      date: sale.createdAt.toIso8601String().split('T').first,
      productName: sale.productName,
      salesperson: sale.salesperson,
      quantity: sale.quantity,
      total: sale.total,
      unitPrice: sale.unitPrice,
    );
  }
}

class CashierDataState {
  final List<Product> products;
  final List<CashierSaleRecord> sales;
  final List<CashierCostRecord> costs;
  final List<CashierStaffMember> staff;
  final List<DailyReportArchive> exportedReports;
  final bool isLoading;

  const CashierDataState({
    this.products = const [],
    this.sales = const [],
    this.costs = const [],
    this.staff = const [],
    this.exportedReports = const [],
    this.isLoading = false,
  });

  CashierDataState copyWith({
    List<Product>? products,
    List<CashierSaleRecord>? sales,
    List<CashierCostRecord>? costs,
    List<CashierStaffMember>? staff,
    List<DailyReportArchive>? exportedReports,
    bool? isLoading,
  }) {
    return CashierDataState(
      products: products ?? this.products,
      sales: sales ?? this.sales,
      costs: costs ?? this.costs,
      staff: staff ?? this.staff,
      exportedReports: exportedReports ?? this.exportedReports,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<StaffPerformanceInfo> staffPerformanceList() {
    return staff.map((member) {
      final staffSales = sales.where((s) => s.salesperson == member.name);
      final totalUnits = staffSales.fold(0, (sum, s) => sum + s.quantity);
      final breakdownMap = <String, int>{};
      for (final sale in staffSales) {
        breakdownMap[sale.productName] =
            (breakdownMap[sale.productName] ?? 0) + sale.quantity;
      }
      final breakdown = breakdownMap.entries
          .map((e) => '.${e.key} - ${e.value}')
          .toList();
      return StaffPerformanceInfo(
        member: member,
        totalUnits: totalUnits,
        breakdown: breakdown,
      );
    }).toList();
  }

  int get totalProductUnits =>
      products.fold(0, (sum, product) => sum + product.stock);

  int incomeForDate(String date) {
    return sales
        .where((sale) => sale.date == date)
        .fold(0, (sum, sale) => sum + sale.total);
  }

  int unitsSoldForDate(String date) {
    return sales
        .where((sale) => sale.date == date)
        .fold(0, (sum, sale) => sum + sale.quantity);
  }

  int transactionsForDate(String date) {
    return sales.where((sale) => sale.date == date).length;
  }

  List<CashierSaleRecord> salesForDate(String date) {
    return sales.where((sale) => sale.date == date).toList();
  }

  int costsForDate(String date) {
    return costs
        .where((cost) => cost.date == date)
        .fold(0, (sum, cost) => sum + cost.amount);
  }

  List<CashierCostRecord> costRecordsForDate(String date) {
    return costs.where((cost) => cost.date == date).toList();
  }

  int netProfitForDate(String date) => incomeForDate(date) - costsForDate(date);
}

class CashierDataNotifier extends Notifier<CashierDataState> {
  @override
  CashierDataState build() {
    ref.listen(sessionProvider, (previous, next) {
      if (next != null && next.role == UserRole.cashier) {
        unawaited(reload());
      } else if (next == null) {
        reset();
      }
    });
    return const CashierDataState();
  }

  int _branchId() {
    final id = ref.read(currentBranchIdProvider);
    return id > 0 ? id : 1;
  }

  void reset() {
    state = const CashierDataState();
  }

  Future<void> reload() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(appRepositoryProvider);
    final branchId = _branchId();
    final products = await repo.getProducts(branchId);
    final sales = await repo.getSales(branchId);
    final costs = await repo.getBranchCosts(branchId);
    final staff = await repo.getStaff(branchId);
    state = CashierDataState(
      products: products,
      sales: sales.map(CashierSaleRecord.fromSale).toList(),
      costs: costs.map(CashierCostRecord.fromBranchCost).toList(),
      staff: staff.map(CashierStaffMember.fromStaff).toList(),
      exportedReports: state.exportedReports,
    );
  }

  int _nextProductId() {
    if (state.products.isEmpty) return 1;
    return state.products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> addProduct({
    required String name,
    required String model,
    required String specification,
    required int sellingPrice,
    required int totalStock,
    required int remainingStock,
    String category = ProductCategories.mobile,
    int? branchId,
  }) async {
    final resolvedBranchId = branchId ?? _branchId();
    final stock = remainingStock > 0 ? remainingStock : totalStock;
    final product = Product(
      id: _nextProductId(),
      name: name,
      model: model,
      specification: specification,
      category: category,
      stock: stock,
      unitPrice: sellingPrice,
      branchId: resolvedBranchId,
    );
    await ref.read(appRepositoryProvider).addProduct(product);
    state = state.copyWith(products: [...state.products, product]);
  }

  Future<void> addStockToProduct(
    int productId,
    int unitsToAdd, {
    int? newSellingPrice,
  }) async {
    if (unitsToAdd <= 0) return;
    Product? updatedProduct;
    final updated = state.products.map((product) {
      if (product.id != productId) return product;
      updatedProduct = product.copyWith(
        stock: product.stock + unitsToAdd,
        unitPrice: newSellingPrice != null && newSellingPrice > 0
            ? newSellingPrice
            : product.unitPrice,
      );
      return updatedProduct!;
    }).toList();
    if (updatedProduct != null) {
      await ref.read(appRepositoryProvider).addProduct(updatedProduct!);
    }
    state = state.copyWith(products: updated);
  }

  Future<void> removeProduct(int productId) async {
    await ref.read(appRepositoryProvider).deleteProduct(productId);
    state = state.copyWith(
      products: state.products.where((p) => p.id != productId).toList(),
    );
  }

  Future<void> updateProduct({
    required int productId,
    required String name,
    required String model,
    required String specification,
    required int sellingPrice,
    required int stock,
  }) async {
    if (name.isEmpty) return;
    Product? updatedProduct;
    final updated = state.products.map((product) {
      if (product.id != productId) return product;
      updatedProduct = product.copyWith(
        name: name,
        model: model,
        specification: specification,
        unitPrice: sellingPrice > 0 ? sellingPrice : product.unitPrice,
        stock: stock >= 0 ? stock : product.stock,
      );
      return updatedProduct!;
    }).toList();
    if (updatedProduct != null) {
      await ref.read(appRepositoryProvider).addProduct(updatedProduct!);
    }
    state = state.copyWith(products: updated);
  }

  int _nextCostId() {
    if (state.costs.isEmpty) return 1;
    return state.costs.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> addCost({
    required String description,
    required int amount,
    String? date,
  }) async {
    if (description.isEmpty || amount <= 0) return;
    final costDate = date ?? DateTime.now().toIso8601String().split('T').first;
    final branchCost = BranchCost(
      id: _nextCostId(),
      branchId: _branchId(),
      title: description,
      amount: amount,
      createdAt: DateTime.tryParse(costDate) ?? DateTime.now(),
    );
    await ref.read(appRepositoryProvider).addBranchCost(branchCost);
    state = state.copyWith(
      costs: [...state.costs, CashierCostRecord.fromBranchCost(branchCost)],
    );
  }

  Future<void> removeCost(int costId) async {
    await ref.read(appRepositoryProvider).deleteBranchCost(costId);
    state = state.copyWith(
      costs: state.costs.where((c) => c.id != costId).toList(),
    );
  }

  int _nextStaffId() {
    if (state.staff.isEmpty) return 1;
    return state.staff.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> addStaff({
    required String name,
    required String phone,
    int? branchId,
  }) async {
    if (name.isEmpty) return;
    final staff = Staff(
      id: _nextStaffId(),
      name: name,
      phone: phone,
      branchId: branchId ?? _branchId(),
    );
    await ref.read(appRepositoryProvider).addStaff(staff);
    state = state.copyWith(
      staff: [...state.staff, CashierStaffMember.fromStaff(staff)],
    );
  }

  Future<void> removeStaff(int staffId) async {
    await ref.read(appRepositoryProvider).deleteStaff(staffId);
    state = state.copyWith(
      staff: state.staff.where((s) => s.id != staffId).toList(),
    );
  }

  int _nextReportId() {
    if (state.exportedReports.isEmpty) return 1;
    return state.exportedReports.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  DailyReportArchive exportToday({String? date, String branchName = 'Cashier Branch'}) {
    final reportDate = date ?? DateTime.now().toIso8601String().split('T').first;
    final report = DailyReportArchive.fromCashierData(
      data: state,
      date: reportDate,
      reportId: _nextReportId(),
      branchName: branchName,
    );
    state = state.copyWith(exportedReports: [...state.exportedReports, report]);
    return report;
  }

  void markReportDeposited(int reportId) {
    state = state.copyWith(
      exportedReports: state.exportedReports
          .map((r) => r.id == reportId ? r.copyWith(isDeposited: true) : r)
          .toList(),
    );
  }

  Future<void> recordSale(Sale sale) async {
    await ref.read(appRepositoryProvider).recordSale(sale);
    final products = await ref.read(appRepositoryProvider).getProducts(_branchId());
    final sales = await ref.read(appRepositoryProvider).getSales(_branchId());
    state = state.copyWith(
      products: products,
      sales: sales.map(CashierSaleRecord.fromSale).toList(),
    );
  }
}

final cashierDataProvider =
    NotifierProvider<CashierDataNotifier, CashierDataState>(
  CashierDataNotifier.new,
);

final cashierDailyMetricsProvider = Provider.family<CashierDailyMetrics, String>(
  (ref, date) {
    final data = ref.watch(cashierDataProvider);
    return CashierDailyMetrics(
      income: data.incomeForDate(date),
      units: data.unitsSoldForDate(date),
      transactions: data.transactionsForDate(date),
      totalProductUnits: data.totalProductUnits,
      sales: data.salesForDate(date),
      costs: data.costsForDate(date),
      netProfit: data.netProfitForDate(date),
      costRecords: data.costRecordsForDate(date),
    );
  },
);

class CashierDailyMetrics {
  final int income;
  final int units;
  final int transactions;
  final int totalProductUnits;
  final List<CashierSaleRecord> sales;
  final int costs;
  final int netProfit;
  final List<CashierCostRecord> costRecords;

  const CashierDailyMetrics({
    required this.income,
    required this.units,
    required this.transactions,
    required this.totalProductUnits,
    required this.sales,
    required this.costs,
    required this.netProfit,
    required this.costRecords,
  });

  String get formattedIncome => BranchFinance.formatMoney(income);
  String get formattedCosts => BranchFinance.formatMoney(costs);
  String get formattedNetProfit => BranchFinance.formatMoney(netProfit);
}
