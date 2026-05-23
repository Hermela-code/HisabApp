import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/providers/cashier_data_provider.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';
import 'package:hisabapp/domain/entities/product.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class CashierDashboard extends ConsumerWidget {
  const CashierDashboard({super.key});

  String _todayString() => DateTime.now().toIso8601String().split('T').first;

  String _formatTodayHeader() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _todayString();
    final metrics = ref.watch(cashierDailyMetricsProvider(today));
    final products = ref.watch(cashierDataProvider).products;
    final lowStockProducts = products.where((p) => p.stock < 5).toList();
    final allSales = ref.watch(cashierDataProvider).sales;
    final recentSales = allSales.length <= 3
        ? allSales.reversed.toList()
        : allSales.sublist(allSales.length - 3).reversed.toList();

    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cashier Dashboard',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTodayHeader(),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 170,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/cashier-record-sale'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: const Text(
                  'Record sale',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              children: [
                _buildStatTile(
                  'Total Product',
                  '${metrics.totalProductUnits}',
                  const Icon(Icons.inventory_2_outlined, color: Colors.black87),
                ),
                _buildStatTile(
                  "Today's Income",
                  metrics.formattedIncome,
                  const Icon(Icons.trending_up, color: Color(0xFF4CAF50)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildLowStockSection(lowStockProducts),
            const SizedBox(height: 20),
            _buildRecentSales(recentSales),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSales(List<CashierSaleRecord> recentSales) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Sales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (recentSales.isEmpty)
            const Text('No recent sales.', style: TextStyle(color: Colors.grey))
          else
            ...recentSales.map(
              (sale) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${sale.productName} · ${sale.salesperson}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      BranchFinance.formatMoney(sale.total),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Widget icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              icon,
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection(List<Product> lowStockProducts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lowStockProducts.isNotEmpty ? Colors.red.shade300 : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Low Stock Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (lowStockProducts.isEmpty)
            const Text('All stock levels are healthy', style: TextStyle(color: Colors.grey))
          else
            ...lowStockProducts.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${product.name}: ${product.stock} units remaining',
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
