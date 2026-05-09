import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Report-2026-04-16', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/owner-exports');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildSummaryBox(title: 'Income', amount: '\$314,000', amountColor: Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryBox(title: 'Op. Cost', amount: '\$3,000', amountColor: Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryBox(title: 'Units', amount: '5', amountColor: Colors.black)),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Product Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  _buildTableHeader(columns: ['Product', 'Model', 'SPEC', 'QTY', 'Revenue']),
                  Divider(thickness: 1.5, color: Colors.grey.shade400, height: 0),
                  _buildTableRow(values: ['Tecno', 'Camon-20', '256/8', '5', '\$100,000']),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Sales by Staff', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  _buildTableHeader(columns: ['Staff', 'Product', 'Model', 'SPEC', 'QTY']),
                  Divider(thickness: 1.5, color: Colors.grey.shade400, height: 0),
                  _buildTableRow(values: ['Helen', 'Tecno', 'Camon-20', '256/8', '5']),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard'))),
                    icon: const Icon(Icons.copy, size: 16, color: Colors.black),
                    label: const Text('Copy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marked as deposited'), backgroundColor: Colors.green)),
                    icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
                    label: const Text('Mark Deposited', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox({required String title, required String amount, required Color amountColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(opacity: 0.5, child: Text(title, style: const TextStyle(fontSize: 11, color: Colors.black))),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: amountColor)),
        ],
      ),
    );
  }

  Widget _buildTableHeader({required List<String> columns}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: columns.map((col) => Expanded(
          child: Text(col, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black)),
        )).toList(),
      ),
    );
  }

  Widget _buildTableRow({required List<String> values}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: values.map((val) => Expanded(
          child: Text(val, style: const TextStyle(fontSize: 11, color: Colors.black)),
        )).toList(),
      ),
    );
  }
}
