import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';

class GoroDetailPage extends StatefulWidget {
  const GoroDetailPage({super.key});

  @override
  State<GoroDetailPage> createState() => _GoroDetailPageState();
}

class _GoroDetailPageState extends State<GoroDetailPage> {
  String _activeTab = 'Stock';

  final List<String> _tabLabels = ['Stock', 'Sales', 'Costs', 'Staff'];

  IconData _tabIcon(String label) {
    switch (label) {
      case 'Stock': return Icons.inventory_2_outlined;
      case 'Sales': return Icons.attach_money;
      case 'Costs': return Icons.money_off;
      case 'Staff': return Icons.people_outline;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OwnerLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goro', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 6),
            Opacity(
              opacity: 0.5,
              child: const Text('Goro, Addis Ababa', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
            const SizedBox(height: 24),

            // Net Profit Engine
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NET PROFIT Engine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _buildMetricCard('Income', '\$340,000', Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Product Cost', '\$945,000', Colors.red)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildMetricCard('Branch Expenses', '\$340,000', Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Op. Costs', '\$340,000', Colors.red)),
                  ]),
                  const SizedBox(height: 12),
                  _buildMetricCard('Net Profit', '-\$607,200', Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _tabLabels.map((label) => GestureDetector(
                onTap: () => setState(() => _activeTab = label),
                child: _buildTabChip(label, _activeTab == label),
              )).toList(),
            ),
            const SizedBox(height: 16),

            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade200,
        border: Border.all(color: isActive ? Colors.amber.shade700 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_tabIcon(label), size: 14, color: isActive ? Colors.amber.shade700 : Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
              color: isActive ? Colors.amber.shade700 : Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'Stock': return _buildStockTab();
      case 'Sales': return _buildSalesTab();
      case 'Costs': return _buildCostsTab();
      case 'Staff': return _buildStaffTab();
      default: return const SizedBox.shrink();
    }
  }

  // STOCK
  Widget _buildStockTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18, color: Colors.black),
            label: const Text('Add Product', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildProductStockCard('Camon-20', '\$20,000', '20', '15'),
        const SizedBox(height: 12),
        _buildProductStockCard('iPhone-17', '\$50,000', '10', '10'),
      ],
    );
  }

  // SALES
  Widget _buildSalesTab() {
    final sales = [
      {'date': '2026-04-08', 'product': 'Techno', 'salesperson': 'Helen', 'qty': '2'},
      {'date': '2026-04-08', 'product': 'iPhone', 'salesperson': 'Helen', 'qty': '1'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.black),
            label: const Text('Record sale', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
              children: ['DATE', 'Product', 'SALESPERSON', 'QTY'].map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(h, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
              )).toList(),
            ),
            ...sales.map((s) => TableRow(
              children: [s['date']!, s['product']!, s['salesperson']!, s['qty']!].map((v) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(v, style: const TextStyle(fontSize: 13)),
              )).toList(),
            )),
          ],
        ),
      ],
    );
  }

  // COSTS
  Widget _buildCostsTab() {
    final costs = [
      {'name': 'Copy', 'date': '2026-04-08', 'amount': '\$200'},
      {'name': 'Transport', 'date': '2026-04-08', 'amount': '\$2000'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18, color: Colors.black),
            label: const Text('Add Cost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...costs.map((c) => Column(
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['name']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(c['date']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                  Text(c['amount']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                ],
              ),
            ),
          ],
        )).toList(),
      ],
    );
  }

  // STAFF
  Widget _buildStaffTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18, color: Colors.black),
            label: const Text('Add Staff', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: Text('No staff recorded.', style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
      ],
    );
  }

  Widget _buildProductStockCard(String name, String price, String units, String totalUnits) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(price, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ]),
          Text('$units / $totalUnits units', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: amountColor)),
      ]),
    );
  }
}
