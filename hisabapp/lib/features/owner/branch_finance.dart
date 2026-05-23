/// Shared finance helpers for owner branch screens.
class BranchFinance {
  BranchFinance._();

  static int parseAmount(String? value) => int.tryParse(value ?? '') ?? 0;

  static String formatMoney(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '${negative ? '-' : ''}\$$buffer';
  }

  /// Revenue from recorded sales (quantity × selling price).
  static int totalIncome(List<Map<String, String>> sales) {
    return sales.fold(0, (sum, sale) => sum + parseAmount(sale['total']));
  }

  /// Cost of goods sold: quantity × unit cost per sale.
  static int totalProductCost(List<Map<String, String>> sales) {
    return sales.fold(0, (sum, sale) => sum + parseAmount(sale['cost_total']));
  }

  /// Operational expenses from the Costs tab.
  static int totalBranchExpenses(List<Map<String, String>> costs) {
    return costs.fold(0, (sum, cost) => sum + parseAmount(cost['amount']));
  }

  static int netProfit({
    required List<Map<String, String>> sales,
    required List<Map<String, String>> costs,
  }) {
    return totalIncome(sales) - totalProductCost(sales) - totalBranchExpenses(costs);
  }

  /// Fill [cost_total] on a sale when missing, using branch stock cost prices.
  static Map<String, String> enrichSale(
    Map<String, String> sale,
    List<Map<String, String>> products,
  ) {
    final enriched = Map<String, String>.from(sale);
    if (enriched['cost_total'] != null && enriched['cost_total']!.isNotEmpty) {
      return enriched;
    }
    final qty = parseAmount(enriched['qty']);
    final productName = enriched['product'] ?? '';
    Map<String, String>? match;
    for (final p in products) {
      if (p['name']?.toLowerCase() == productName.toLowerCase() ||
          p['brand']?.toLowerCase() == productName.toLowerCase()) {
        match = p;
        break;
      }
    }
    if (match != null) {
      final unitCost = parseAmount(match['cost_price']);
      enriched['cost_total'] = (unitCost * qty).toString();
    }
    if (enriched['total'] == null || enriched['total']!.isEmpty) {
      final unitPrice = parseAmount(match?['price']);
      enriched['total'] = (unitPrice * qty).toString();
    }
    return enriched;
  }
}
