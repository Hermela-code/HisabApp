import '../providers/cashier_data_provider.dart';
import '../../features/owner/branch_finance.dart';

class DailyReportProductRow {
  final String productName;
  final String model;
  final String specification;
  final int quantity;
  final int revenue;

  const DailyReportProductRow({
    required this.productName,
    required this.model,
    required this.specification,
    required this.quantity,
    required this.revenue,
  });
}

class DailyReportStaffRow {
  final String staffName;
  final String productName;
  final String model;
  final String specification;
  final int quantity;

  const DailyReportStaffRow({
    required this.staffName,
    required this.productName,
    required this.model,
    required this.specification,
    required this.quantity,
  });
}

class DailyReportArchive {
  final int id;
  final String date;
  final String branchName;
  final int income;
  final int operationalCost;
  final int totalUnits;
  final int distinctProducts;
  final int totalProductStock;
  final bool isDeposited;
  final List<DailyReportProductRow> productRows;
  final List<DailyReportStaffRow> staffRows;

  const DailyReportArchive({
    required this.id,
    required this.date,
    required this.branchName,
    required this.income,
    required this.operationalCost,
    required this.totalUnits,
    required this.distinctProducts,
    this.totalProductStock = 0,
    this.isDeposited = false,
    this.productRows = const [],
    this.staffRows = const [],
  });

  DailyReportArchive copyWith({bool? isDeposited}) {
    return DailyReportArchive(
      id: id,
      date: date,
      branchName: branchName,
      income: income,
      operationalCost: operationalCost,
      totalUnits: totalUnits,
      distinctProducts: distinctProducts,
      totalProductStock: totalProductStock,
      isDeposited: isDeposited ?? this.isDeposited,
      productRows: productRows,
      staffRows: staffRows,
    );
  }

  String get formattedIncome => BranchFinance.formatMoney(income);
  String get formattedOperationalCost => BranchFinance.formatMoney(operationalCost);
  String get titleLabel => 'Report-$date';

  String toClipboardText({bool cashierSummary = false}) {
    final buffer = StringBuffer()
      ..writeln(titleLabel)
      ..writeln('Branch: $branchName')
      ..writeln('Income: $formattedIncome');
    if (cashierSummary) {
      buffer.writeln('Total Product: $totalProductStock units');
    } else {
      buffer
        ..writeln('Op. Cost: $formattedOperationalCost')
        ..writeln('Units: $totalUnits');
    }
    buffer
      ..writeln()
      ..writeln('Product Summary');
    for (final row in productRows) {
      buffer.writeln(
        '${row.productName} | ${row.model} | ${row.specification} | ${row.quantity} | ${BranchFinance.formatMoney(row.revenue)}',
      );
    }
    buffer.writeln();
    buffer.writeln('Sales by Staff');
    for (final row in staffRows) {
      buffer.writeln(
        '${row.staffName} | ${row.productName} | ${row.model} | ${row.specification} | ${row.quantity}',
      );
    }
    return buffer.toString();
  }

  static DailyReportArchive fromCashierData({
    required CashierDataState data,
    required String date,
    required int reportId,
    String branchName = 'Cashier Branch',
  }) {
    final daySales = data.salesForDate(date);
    final income = data.incomeForDate(date);
    final opCost = data.costsForDate(date);
    final units = data.unitsSoldForDate(date);

    ProductLookup lookup(String productName) {
      for (final product in data.products) {
        if (product.name == productName) {
          return ProductLookup(product.model, product.specification);
        }
      }
      return const ProductLookup('-', '-');
    }

    final productAgg = <String, DailyReportProductRow>{};
    final staffRows = <DailyReportStaffRow>[];

    for (final sale in daySales) {
      final info = lookup(sale.productName);
      final key = '${sale.productName}|${info.model}|${info.specification}';
      final existing = productAgg[key];
      if (existing == null) {
        productAgg[key] = DailyReportProductRow(
          productName: sale.productName,
          model: info.model,
          specification: info.specification,
          quantity: sale.quantity,
          revenue: sale.total,
        );
      } else {
        productAgg[key] = DailyReportProductRow(
          productName: existing.productName,
          model: existing.model,
          specification: existing.specification,
          quantity: existing.quantity + sale.quantity,
          revenue: existing.revenue + sale.total,
        );
      }

      staffRows.add(
        DailyReportStaffRow(
          staffName: sale.salesperson,
          productName: sale.productName,
          model: info.model,
          specification: info.specification,
          quantity: sale.quantity,
        ),
      );
    }

    return DailyReportArchive(
      id: reportId,
      date: date,
      branchName: branchName,
      income: income,
      operationalCost: opCost,
      totalUnits: units,
      distinctProducts: productAgg.length,
      totalProductStock: data.totalProductUnits,
      productRows: productAgg.values.toList(),
      staffRows: staffRows,
    );
  }

  static DailyReportArchive fromOwnerBranch({
    required String branchName,
    required String date,
    required int reportId,
    required List<Map<String, String>> sales,
    required List<Map<String, String>> products,
    required List<Map<String, String>> costs,
  }) {
    var income = 0;
    var units = 0;
    final productAgg = <String, DailyReportProductRow>{};
    final staffRows = <DailyReportStaffRow>[];

    ProductLookup lookup(String productName) {
      for (final product in products) {
        if (product['name'] == productName) {
          return ProductLookup(
            product['brand'] ?? '-',
            product['spec'] ?? '-',
          );
        }
      }
      return const ProductLookup('-', '-');
    }

    for (final sale in sales) {
      final productName = sale['product'] ?? '';
      final qty = int.tryParse(sale['qty'] ?? '0') ?? 0;
      final total = int.tryParse(sale['total'] ?? '0') ?? 0;
      final salesperson = sale['salesperson'] ?? '';
      final info = lookup(productName);

      income += total;
      units += qty;

      final key = '$productName|${info.model}|${info.specification}';
      final existing = productAgg[key];
      if (existing == null) {
        productAgg[key] = DailyReportProductRow(
          productName: productName,
          model: info.model,
          specification: info.specification,
          quantity: qty,
          revenue: total,
        );
      } else {
        productAgg[key] = DailyReportProductRow(
          productName: existing.productName,
          model: existing.model,
          specification: existing.specification,
          quantity: existing.quantity + qty,
          revenue: existing.revenue + total,
        );
      }

      staffRows.add(
        DailyReportStaffRow(
          staffName: salesperson,
          productName: productName,
          model: info.model,
          specification: info.specification,
          quantity: qty,
        ),
      );
    }

    var opCost = 0;
    for (final cost in costs) {
      opCost += int.tryParse(cost['amount'] ?? '0') ?? 0;
    }

    return DailyReportArchive(
      id: reportId,
      date: date,
      branchName: branchName,
      income: income,
      operationalCost: opCost,
      totalUnits: units,
      distinctProducts: productAgg.length,
      productRows: productAgg.values.toList(),
      staffRows: staffRows,
    );
  }
}

class ProductLookup {
  final String model;
  final String specification;
  const ProductLookup(this.model, this.specification);
}

enum ReportSource { cashier, owner }

class ReportNavigationArgs {
  final DailyReportArchive report;
  final String returnRoute;
  final ReportSource source;

  const ReportNavigationArgs({
    required this.report,
    required this.returnRoute,
    required this.source,
  });
}
