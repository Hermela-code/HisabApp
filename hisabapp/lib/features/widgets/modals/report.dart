import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Report-2026-04-16'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildSummaryBox(title: 'Income', amount: '\$314,000', amountColor: Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryBox(title: 'Op. Cost', amount: '\$3,000', amountColor: Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryBox(title: 'Units', amount: '5', amountColor: Colors.black)),
              ],
            ),
            const SizedBox(height: 32),

            const Text('Product Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildTableHeader(columns: ['Product', 'Model', 'SPEC', 'QTY', 'Revenue']),
                  Divider(thickness: 2, color: Colors.grey.shade400, height: 0),
                  _buildTableRow(values: ['Tecno', 'Camon-20', '256/8', '5', '\$100,000']),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Sales by Staff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildTableHeader(columns: ['Staff', 'Product', 'Model', 'SPEC', 'QTY']),
                  Divider(thickness: 2, color: Colors.grey.shade400, height: 0),
                  _buildTableRow(values: ['Helen', 'Tecno', 'Camon-20', '256/8', '5']),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard'))),
                    icon: const Icon(Icons.copy, size: 18, color: Colors.black),
                    label: const Text('Copy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marked as deposited'), backgroundColor: Colors.green)),
                    icon: const Icon(Icons.check_circle, size: 18, color: Colors.white),
                    label: const Text('Mark Deposited', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox({required String title, required String amount, required Color amountColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(opacity: 0.5, child: Text(title, style: const TextStyle(fontSize: 13, color: Colors.black))),
          const SizedBox(height: 6),
          Text(amount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: amountColor)),
        ],
      ),
    );
  }

  Widget _buildTableHeader({required List<String> columns}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: columns.map((col) => Expanded(
          child: Text(col, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
        )).toList(),
      ),
    );
  }

  Widget _buildTableRow({required List<String> values}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: values.map((val) => Expanded(
          child: Text(val, style: const TextStyle(fontSize: 13, color: Colors.black)),
        )).toList(),
      ),
    );
  }
}
