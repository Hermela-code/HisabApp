import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';

class ExportArchive extends StatelessWidget {
  const ExportArchive({super.key});

  @override
  Widget build(BuildContext context) {
    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Export / Archive",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Close and archive daily reports",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Export Today Button
            SizedBox(
              width: 180,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Connect to BLoC to handle the export/close day logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: const Text(
                  "Export Today",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black54),
                  hintText: "Search by date (yyyy-mm-dd)...",
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Archive List
            _buildArchiveCard(
              context,
              date: "2026-04-08",
              amount: "\$90,000",
              units: "3 units . 2 products",
              costs: "-\$0 costs",
              status: "Pending",
              statusColor: Colors.amber,
            ),
            const SizedBox(height: 16),
            _buildArchiveCard(
              context,
              date: "2026-04-08",
              amount: "\$60,000",
              units: "3 units . 1 products",
              costs: "-\$200 costs",
              status: "Deposited",
              statusColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveCard(
    BuildContext context, {
    required String date,
    required String amount,
    required String units,
    required String costs,
    required String status,
    required Color statusColor,
  }) {
    return GestureDetector(
      onTap: () => context.push('/owner-report'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.history, color: Colors.black54, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(units, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                Text(costs, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == "Pending")
                      Icon(Icons.access_time, size: 12, color: statusColor)
                    else
                      Icon(Icons.check_circle_outline, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
