import 'package:flutter/material.dart';
// Importing the shared core widget for domain-validated inputs
import '../../core/presentation/widgets/hisab_text_field.dart';

class BranchCost extends StatelessWidget {
  const BranchCost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(Icons.menu, color: Colors.black87, size: 28),
        ),
        title: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: Color(0xFFF2A007), size: 24),
            const SizedBox(width: 8),
            Text(
              "HisabApp",
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
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
                onPressed: () {
                  // This will trigger the BLoC to handle the "Create" part of CRUD
                },
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
            _buildCostItem("Transport", "2026-04-08", "\$200"),
            const SizedBox(height: 16),
            _buildCostItem("Copy", "2026-04-08", "\$300"),
          ],
        ),
      ),
    );
  }

  // Helper for the cost items to match photo_2_2026-04-27_12-57-04_2.jpg
  Widget _buildCostItem(String title, String date, String amount) {
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
                onPressed: () {
                  // Hook for the "Delete" requirement of CRUD[cite: 1]
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
