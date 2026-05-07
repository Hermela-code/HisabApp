import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';

class DailySales extends StatelessWidget {
  const DailySales({super.key});

  @override
  Widget build(BuildContext context) {
    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily Sales",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "View sales by date",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Date Selection Row
            Row(
              children: [
                const Text("Date", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    children: [
                      Text("4/10/2026", style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 40),
                      Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search/Category Bar
            const Text("Search", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, size: 20),
                  hintText: "Select Category",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Metrics Row
            Row(
              children: [
                _buildSmallMetric("Today's Income", "\$90,000", isCurrency: true),
                const SizedBox(width: 8),
                _buildSmallMetric("Units", "3"),
                const SizedBox(width: 8),
                _buildSmallMetric("Transaction", "2", isCurrency: true),
              ],
            ),
            const SizedBox(height: 30),

            // Sales Table Container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Table Header
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(child: Text("PRODUCT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("SALESPERSON", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Text("QTY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        SizedBox(width: 30),
                        Text("TOTAL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Table Rows
                  _buildSalesRow("iphone", "Samuel", "1", "\$50,000"),
                  _buildSalesRow("tecno", "Hana", "2", "\$40,000"),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallMetric(String title, String value, {bool isCurrency = false}) {
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
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
