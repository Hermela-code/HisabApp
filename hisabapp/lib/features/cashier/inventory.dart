import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_product.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_stock.dart';
import 'package:hisabapp/core/presentation/widgets/modals/delete.dart';
import 'package:hisabapp/core/presentation/widgets/modals/update_product.dart';

class Inventory extends StatelessWidget {
  const Inventory({super.key});

  void _showBlurModal(BuildContext context, Widget modal) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: modal,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String name) {
    _showBlurModal(context, const DeleteProductView());
  }

  @override
  Widget build(BuildContext context) {
    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inventory', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('3 products', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),

            SizedBox(
              width: 170,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => _showBlurModal(context, const AddProductView()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 24),

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
                  hintText: 'Search products...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildProductCard(context, name: 'Camon-20', subcategory: 'Mobile', brand: 'Tecno', spec: '256/8', price: '\$20,000', units: '20 units'),
            const SizedBox(height: 16),
            _buildProductCard(context, name: 'iphone-17', subcategory: 'Mobile', brand: 'iphone', spec: '256/8', price: '\$50,000', units: '10 units'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, {
    required String name,
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
                decoration: BoxDecoration(color: const Color(0xFFC4F8C1), borderRadius: BorderRadius.circular(8)),
                child: Text(units, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Electronics', subcategory),
              _buildDetailItem('Product', brand),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Specification', spec),
              _buildDetailItem('Selling Price', price),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showBlurModal(context, const AddStockScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Stock'),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showBlurModal(context, const UpdateProductView()),
                child: const Icon(Icons.edit_outlined, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showDeleteDialog(context, name),
                child: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
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
