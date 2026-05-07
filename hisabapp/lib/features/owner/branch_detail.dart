import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';
import 'package:hisabapp/core/presentation/widgets/hisab_cards.dart';

class GoroDetailPage extends StatelessWidget {
  const GoroDetailPage({super.key});

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

            // Net Profit Engine Box
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
                  const Text('Net Profit Engine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _buildSmallMetricCard('Income', '\$340,000', Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSmallMetricCard('Product Cost', '\$945,000', Colors.red)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildSmallMetricCard('Branch Expenses', '\$340,000', Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSmallMetricCard('Made Profit', '-\$607,200', Colors.red)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterChip(Icons.inventory_2_outlined, 'Stock', true),
                _buildFilterChip(Icons.attach_money, 'Sales', false),
                _buildFilterChip(Icons.money_off, 'Costs', false),
                _buildFilterChip(Icons.people_outline, 'Staff', false),
              ],
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 24),

            // Product Card using shared ProductStockCard design
            ProductStockCard(
              name: 'Camon-20',
              price: '\$20,000',
              units: '20',
              totalUnits: '15',
            ),
            const SizedBox(height: 16),
            ProductStockCard(
              name: 'iPhone-17',
              price: '\$50,000',
              units: '10',
              totalUnits: '10',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallMetricCard(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: amountColor)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, bool isActive) {
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
          Icon(icon, size: 16, color: isActive ? Colors.amber.shade700 : Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.amber.shade700 : Colors.grey.shade700)),
        ],
      ),
    );
  }

}
