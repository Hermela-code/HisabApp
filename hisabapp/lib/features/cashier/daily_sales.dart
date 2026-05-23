import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabapp/application/providers/cashier_data_provider.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class DailySales extends ConsumerStatefulWidget {
  const DailySales({super.key});

  @override
  ConsumerState<DailySales> createState() => _DailySalesState();
}

class _DailySalesState extends ConsumerState<DailySales> {
  late String _selectedDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = _todayString();
  }

  String _todayString() => DateTime.now().toIso8601String().split('T').first;

  String _formatDisplayDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[1]}/${parts[2]}/${parts[0]}';
  }

  List<CashierSaleRecord> _filteredSales(List<CashierSaleRecord> sales) {
    if (_searchQuery.isEmpty) return sales;
    final query = _searchQuery.toLowerCase();
    return sales
        .where(
          (sale) =>
              sale.productName.toLowerCase().contains(query) ||
              sale.salesperson.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(cashierDailyMetricsProvider(_selectedDate));
    final filtered = _filteredSales(metrics.sales);

    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Sales',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'View sales by date',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_selectedDate) ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked.toIso8601String().split('T').first;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _formatDisplayDate(_selectedDate),
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(width: 40),
                        const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Search', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, size: 20),
                  hintText: 'Search product or salesperson',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildSmallMetric("Today's Income", metrics.formattedIncome, isCurrency: true),
                const SizedBox(width: 8),
                _buildSmallMetric('Units Sold', '${metrics.units}'),
                const SizedBox(width: 8),
                _buildSmallMetric('Transactions', '${metrics.transactions}'),
              ],
            ),
            const SizedBox(height: 12),
            _buildSmallMetricWide(
              'Total Product (in stock)',
              '${metrics.totalProductUnits} units',
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(child: Text('PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(child: Text('SALESPERSON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Text('QTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        SizedBox(width: 30),
                        Text('TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        metrics.sales.isEmpty
                            ? 'No sales recorded for this date. Record a sale to see it here.'
                            : 'No sales match your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    )
                  else
                    ...filtered.map(
                      (sale) => _buildSalesRow(
                        sale.productName,
                        sale.salesperson,
                        '${sale.quantity}',
                        BranchFinance.formatMoney(sale.total),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallMetricWide(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String title, String value, {bool isCurrency = false, Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(title, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600)),
                ),
                if (isCurrency) const Icon(Icons.trending_up, color: Colors.green, size: 14),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesRow(String product, String seller, String qty, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(product, style: const TextStyle(fontSize: 13))),
          Expanded(child: Text(seller, style: const TextStyle(fontSize: 13))),
          Text(qty, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 30),
          Text(total, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
