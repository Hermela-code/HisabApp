import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';

class Inventory extends StatelessWidget {
  const Inventory({super.key});

  @override
  Widget build(BuildContext context) {
    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Inventory",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "3 products",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Add Product Button
            SizedBox(
              width: 170,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Connect to BLoC to open "Add Product" flow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  "Add Product",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black54),
                  hintText: "Search products...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product List
            _buildProductCard(
              name: "Camon-20",
              category: "Electronics",
              subcategory: "Mobile",
              brand: "Tecno",
              spec: "256/8",
              price: "\$20,000",
              units: "20 units",
            ),
            const SizedBox(height: 16),
            _buildProductCard(
              name: "iphone-17",
              category: "Electronics",
              subcategory: "Mobile",
              brand: "iphone",
              spec: "256/8",
              price: "\$50,000",
              units: "10 units",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String category,
    required String subcategory,
    required String brand,
    required String spec,
    required String price,
    required String units,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  units,
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem("Electronics", subcategory),
              _buildDetailItem("Product", brand),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem("Specification", spec),
              _buildDetailItem("Selling Price", price),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B2A), // Dark Navy button
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Stock"),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.edit_outlined, color: Colors.black54),
              const SizedBox(width: 12),
              const Icon(Icons.delete_outline, color: Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}