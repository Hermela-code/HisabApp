import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabapp/application/providers/cashier_data_provider.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_product.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_stock.dart';
import 'package:hisabapp/core/presentation/widgets/modals/delete.dart';
import 'package:hisabapp/core/presentation/widgets/modals/update_product.dart';
import 'package:hisabapp/domain/entities/product.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class Inventory extends ConsumerStatefulWidget {
  const Inventory({super.key});

  @override
  ConsumerState<Inventory> createState() => _InventoryState();
}

class _InventoryState extends ConsumerState<Inventory> {
  String _searchQuery = '';

  void _showBlurModal(Widget modal) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: modal,
      ),
    );
  }

  void _showAddProductModal() {
    _showBlurModal(
      AddProductView(
        showCostFields: false,
        onAddProduct: (category, name, model, spec, sellingPrice, costPrice, totalStock, remainingStock) {
          ref.read(cashierDataProvider.notifier).addProduct(
                category: category,
                name: name,
                model: model,
                specification: spec,
                sellingPrice: sellingPrice,
                totalStock: totalStock,
                remainingStock: remainingStock,
              );
        },
      ),
    );
  }

  void _showAddStockModal(Product product) {
    _showBlurModal(
      AddStockScreen(
        showCostFields: false,
        currentStock: product.stock,
        onAddStock: (unitsToAdd, newSellingPrice, newCostPrice) {
          ref.read(cashierDataProvider.notifier).addStockToProduct(
                product.id,
                unitsToAdd,
                newSellingPrice: newSellingPrice,
              );
        },
      ),
    );
  }

  void _showEditProductModal(Product product) {
    _showBlurModal(
      UpdateProductView(
        showCostFields: false,
        initialName: product.name,
        initialModel: product.model,
        initialSpecification: product.specification,
        initialSellingPrice: product.unitPrice,
        initialStock: product.stock,
        onUpdate: (name, model, spec, sellingPrice, costPrice, stock) {
          ref.read(cashierDataProvider.notifier).updateProduct(
                productId: product.id,
                name: name,
                model: model,
                specification: spec,
                sellingPrice: sellingPrice,
                stock: stock,
              );
        },
      ),
    );
  }

  void _showDeleteDialog(Product product) {
    _showBlurModal(
      DeleteProductView(
        productName: product.name,
        onDelete: () {
          ref.read(cashierDataProvider.notifier).removeProduct(product.id);
        },
      ),
    );
  }

  List<Product> _filteredProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.model.toLowerCase().contains(query) ||
              p.specification.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(cashierDataProvider).products;
    final filtered = _filteredProducts(products);
    final countLabel = products.length == 1 ? '1 product' : '${products.length} products';

    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(countLabel, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              width: 170,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: _showAddProductModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add Product',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
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
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black54),
                  hintText: 'Search products...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.trim()),
              ),
            ),
            const SizedBox(height: 24),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    products.isEmpty
                        ? 'No products yet. Tap Add Product to create one.'
                        : 'No products match your search.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...filtered.asMap().entries.expand((entry) {
                final index = entry.key;
                final product = entry.value;
                return [
                  if (index > 0) const SizedBox(height: 16),
                  _buildProductCard(context, product),
                ];
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final priceLabel = BranchFinance.formatMoney(product.unitPrice);
    final unitsLabel = '${product.stock} units';
    final isLowStock = product.stock < 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowStock ? Colors.red.shade600 : Colors.grey.shade300,
          width: isLowStock ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock ? Colors.red.shade50 : const Color(0xFFC4F8C1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unitsLabel,
                  style: TextStyle(
                    color: isLowStock ? Colors.red.shade800 : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Electronics', 'Mobile'),
              _buildDetailItem('Product', product.model),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Specification', product.specification),
              _buildDetailItem('Selling Price', priceLabel),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddStockModal(product),
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
                onTap: () => _showEditProductModal(product),
                child: const Icon(Icons.edit_outlined, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showDeleteDialog(product),
                child: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
