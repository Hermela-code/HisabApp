import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../features/owner/branch_finance.dart';

/// Converts between owner UI maps and domain entities for SQLite persistence.
class BranchDataMapper {
  static Map<String, String> productToMap(Product product, {int? costPrice}) {
    final resolvedCostPrice = costPrice ?? product.costPrice;
    return {
      'id': product.id.toString(),
      'name': product.name,
      'brand': product.model,
      'mobile': product.electronicsType,
      'spec': product.specification,
      'price': product.unitPrice.toString(),
      'cost_price': resolvedCostPrice.toString(),
      'units': product.stock.toString(),
    };
  }

  static Product productFromMap(Map<String, String> map, int id, int branchId) {
    final resolvedId = int.tryParse(map['id'] ?? '') ?? id;
    return Product(
      id: resolvedId,
      name: map['name'] ?? '',
      model: map['brand'] ?? '',
      specification: map['spec'] ?? '',
      category: map['mobile'] ?? ProductCategories.mobile,
      stock: int.tryParse(map['units'] ?? '0') ?? 0,
      unitPrice: int.tryParse(map['price'] ?? '0') ?? 0,
      costPrice: int.tryParse(map['cost_price'] ?? '0') ?? 0,
      branchId: branchId,
    );
  }

  static Map<String, String> saleToMap(Sale sale, {int? costTotal}) {
    final resolvedCostTotal = costTotal ?? sale.costTotal;
    return {
      'id': sale.id.toString(),
      'product_id': sale.productId.toString(),
      'unit_price': sale.unitPrice.toString(),
      'date': sale.createdAt.toIso8601String().split('T').first,
      'product': sale.productName,
      'salesperson': sale.salesperson,
      'qty': sale.quantity.toString(),
      'total': sale.total.toString(),
      'cost_total': resolvedCostTotal.toString(),
    };
  }

  static Sale saleFromMap(Map<String, String> map, int id, int branchId, {int productId = 0}) {
    final date = map['date'] ?? DateTime.now().toIso8601String().split('T').first;
    final resolvedId = int.tryParse(map['id'] ?? '') ?? id;
    final resolvedProductId = int.tryParse(map['product_id'] ?? '') ?? productId;
    return Sale(
      id: resolvedId,
      productId: resolvedProductId,
      productName: map['product'] ?? '',
      salesperson: map['salesperson'] ?? '',
      quantity: int.tryParse(map['qty'] ?? '0') ?? 0,
      unitPrice: int.tryParse(map['unit_price'] ?? '0') ?? 0,
      total: int.tryParse(map['total'] ?? '0') ?? 0,
      costTotal: int.tryParse(map['cost_total'] ?? '0') ?? 0,
      createdAt: DateTime.tryParse(date) ?? DateTime.now(),
      branchId: branchId,
    );
  }

  static Map<String, String> costToMap(BranchCost cost) {
    return {
      'id': cost.id.toString(),
      'description': cost.title,
      'date': cost.createdAt.toIso8601String().split('T').first,
      'amount': cost.amount.toString(),
    };
  }

  static BranchCost costFromMap(Map<String, String> map, int id, int branchId) {
    final dateStr = map['date'] ?? DateTime.now().toIso8601String().split('T').first;
    final resolvedId = int.tryParse(map['id'] ?? '') ?? id;
    return BranchCost(
      id: resolvedId,
      branchId: branchId,
      title: map['description'] ?? '',
      amount: int.tryParse(map['amount'] ?? '0') ?? 0,
      createdAt: DateTime.tryParse(dateStr) ?? DateTime.now(),
    );
  }

  static Map<String, String> staffToMap(Staff staff, {List<Sale> sales = const []}) {
    final memberSales = sales.where((s) => s.salesperson == staff.name);
    final totalUnits = memberSales.fold(0, (sum, s) => sum + s.quantity);
    final breakdownMap = <String, int>{};
    for (final sale in memberSales) {
      breakdownMap[sale.productName] = (breakdownMap[sale.productName] ?? 0) + sale.quantity;
    }
    final breakdown = breakdownMap.entries.map((e) => '.${e.key} - ${e.value}').join(', ');
    return {
      'id': staff.id.toString(),
      'name': staff.name,
      'phone': staff.phone,
      'units': '$totalUnits units',
      'products': breakdown,
    };
  }

  static Staff staffFromMap(Map<String, String> map, int id, int branchId) {
    final resolvedId = int.tryParse(map['id'] ?? '') ?? id;
    return Staff(
      id: resolvedId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      branchId: branchId,
    );
  }

  static List<Map<String, String>> enrichSales(
    List<Map<String, String>> sales,
    List<Map<String, String>> products,
  ) {
    return sales.map((s) => BranchFinance.enrichSale(s, products)).toList();
  }
}
