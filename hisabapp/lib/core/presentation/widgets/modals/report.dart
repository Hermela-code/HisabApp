import 'package:flutter/material.dart';

class DailyReportModal extends StatelessWidget {
  const DailyReportModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        const Expanded(
                          child: Text(
                            'REport-2026-04-16',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Top Metric Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricCard("Income", "\$340,000", Colors.green),
                        _buildMetricCard("Op. Costs", "\$3,000", Colors.red),
                        _buildMetricCard("Units", "5", Colors.black),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Product Summary Table
                    _buildSectionHeader("Product Summery"),
                    _buildSummaryTable(
                      headers: ['Product', 'model', 'Spec', 'Qty', 'REvenue'],
                      rows: [['tecno', 'Camon-20', '256/8', '5', '\$100,00']],
                    ),
                    const SizedBox(height: 25),

                    // Sales by Staff Table
                    _buildSectionHeader("Sales by staff"),
                    _buildSummaryTable(
                      headers: ['Staff', 'Product', 'model', 'Spec', 'Qty'],
                      rows: [['Helen', 'tecno', 'Camon-20', '256/8', '5']],
                    ),
                    const SizedBox(height: 30),

                    // Footer Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.copy, size: 18, color: Colors.black),
                            label: const Text("Copy", style: TextStyle(color: Colors.black)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text("Mark Deposited"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color valueColor) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryTable({required List<String> headers, required List<List<String>> rows}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table Header Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: headers.map((h) => Expanded(
                child: Text(h, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
              )).toList(),
            ),
          ),
          const Divider(height: 1),
          // Table Data Rows
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((cell) => Expanded(
                child: Text(cell, style: const TextStyle(fontSize: 11))
              )).toList(),
            ),
          )),
        ],
      ),
    );
  }
}