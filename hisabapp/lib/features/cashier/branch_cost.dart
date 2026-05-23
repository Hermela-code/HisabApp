import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/presentation/widgets/cashier_header.dart';
import '../../core/presentation/widgets/modals/add_branchcost.dart';
import '../../core/presentation/widgets/modals/delete.dart';

class BranchCost extends StatelessWidget {
  const BranchCost({super.key});

  void _showAddCostModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: const AddBranchCostModal(),
      ),
    );
  }

  void _showDeleteModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: const DeleteProductView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Branch Costs",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Track daily expenses",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Add Cost Button
            SizedBox(
              width: 160,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => _showAddCostModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  "Add Cost",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Date Picker and Total Cost Summary Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Date", style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: "04/08/2026",
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: "04/08/2026", child: Text("04/08/2026")),
                            ],
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Text("Total Costs", style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text("\$200", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // List of Cost Items (Represents the "Read" part of CRUD)
            _buildCostItem(context, "Transport", "2026-04-08", "\$200"),
            const SizedBox(height: 16),
            _buildCostItem(context, "Copy", "2026-04-08", "\$300"),
          ],
        ),
      ),
    );
  }

  // Helper for the cost items to match photo_2_2026-04-27_12-57-04_2.jpg
  Widget _buildCostItem(BuildContext context, String title, String date, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Text(
                amount,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                onPressed: () => _showDeleteModal(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
