import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/cashier_data_provider.dart';
import '../../core/presentation/widgets/cashier_header.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';

class RecordSalePage extends ConsumerStatefulWidget {
  const RecordSalePage({super.key});

  @override
  ConsumerState<RecordSalePage> createState() => _RecordSalePageState();
}

class _RecordSalePageState extends ConsumerState<RecordSalePage> {
  // Dropdown selections
  String? selectedElectronicsType;
  String? selectedProductName;
  String? selectedModel;
  String? selectedSpecification;
  String? selectedSalesperson;

  // Text field controllers
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  void updateTotal() {
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final unitPrice = int.tryParse(unitPriceController.text) ?? 0;
    totalController.text = (quantity * unitPrice).toString();
  }

  @override
  void initState() {
    super.initState();
    quantityController.addListener(updateTotal);
    unitPriceController.addListener(updateTotal);
  }

  List<Product> _inStock(List<Product> products) =>
      products.where((p) => p.stock > 0).toList();

  List<Product> _byCategory(List<Product> products) {
    if (selectedElectronicsType == null) return products;
    return products
        .where(
          (p) =>
              p.electronicsType.toLowerCase() ==
              selectedElectronicsType!.toLowerCase(),
        )
        .toList();
  }

  List<String> _productNames(List<Product> inStock) => _byCategory(inStock)
      .map((p) => p.name)
      .toSet()
      .toList();

  List<String> _models(List<Product> inStock) {
    final scoped = _byCategory(inStock).where(
      (p) => selectedProductName == null || p.name == selectedProductName,
    );
    return scoped.map((p) => p.model).toSet().toList();
  }

  List<String> _specifications(List<Product> inStock) {
    return _byCategory(inStock)
        .where((p) {
          if (selectedProductName != null && p.name != selectedProductName) {
            return false;
          }
          if (selectedModel != null && p.model != selectedModel) {
            return false;
          }
          return true;
        })
        .map((p) => p.specification)
        .toSet()
        .toList();
  }

  Product? _selectedProduct(List<Product> products) {
    if (selectedElectronicsType == null ||
        selectedProductName == null ||
        selectedModel == null ||
        selectedSpecification == null) {
      return null;
    }
    try {
      return products.firstWhere(
        (product) =>
            product.electronicsType.toLowerCase() ==
                selectedElectronicsType!.toLowerCase() &&
            product.name == selectedProductName &&
            product.model == selectedModel &&
            product.specification == selectedSpecification,
      );
    } catch (_) {
      return null;
    }
  }

  void _updateSelectedProductFields(List<Product> products) {
    final product = _selectedProduct(products);
    if (product != null) {
      unitPriceController.text = product.unitPrice.toString();
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    totalController.dispose();
    customerNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    String hint,
    ValueChanged<String?>? onChanged,
  ) {
    final enabled = onChanged != null && items.isNotEmpty;
    final selected = value != null && items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selected,
              hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
              items: enabled
                  ? items
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList()
                  : const [],
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cashierData = ref.watch(cashierDataProvider);
    final allProducts = cashierData.products;
    final inStock = _inStock(allProducts);
    final salespersons = cashierData.staff.map((s) => s.name).toList();
    final hasStock = inStock.isNotEmpty;
    final hasStaff = salespersons.isNotEmpty;

    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading: Record Sale
            const Text(
              'Record Sale',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle: Log New Transaction (low opacity)
            Opacity(
              opacity: 0.5,
              child: const Text(
                'Log New Transaction',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            if (!hasStock || !hasStaff) ...[
              const SizedBox(height: 12),
              if (!hasStock)
                Text(
                  'No products in stock. Add products in Inventory first.',
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
                ),
              if (!hasStaff)
                Text(
                  'No staff registered. Add staff on the Staff page first.',
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
                ),
            ],
            const SizedBox(height: 24),

            // Main input box
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    'Electronics Type',
                    ProductCategories.all,
                    selectedElectronicsType,
                    'Select type',
                    hasStock
                        ? (value) {
                            setState(() {
                              selectedElectronicsType = value;
                              selectedProductName = null;
                              selectedModel = null;
                              selectedSpecification = null;
                              unitPriceController.clear();
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Product Name',
                    _productNames(inStock),
                    selectedProductName,
                    'Select product',
                    hasStock && selectedElectronicsType != null
                        ? (value) {
                            setState(() {
                              selectedProductName = value;
                              selectedModel = null;
                              selectedSpecification = null;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Model',
                    _models(inStock),
                    selectedModel,
                    'Select Model',
                    hasStock &&
                            selectedElectronicsType != null &&
                            selectedProductName != null
                        ? (value) {
                            setState(() {
                              selectedModel = value;
                              selectedSpecification = null;
                              _updateSelectedProductFields(allProducts);
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Specification',
                    _specifications(inStock),
                    selectedSpecification,
                    'Select Specification',
                    hasStock &&
                            selectedElectronicsType != null &&
                            selectedProductName != null &&
                            selectedModel != null
                        ? (value) {
                            setState(() {
                              selectedSpecification = value;
                              _updateSelectedProductFields(allProducts);
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // 3-column row: Quantity, Unit Price, Total
                  Row(
                    children: [
                      // Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '1',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Unit Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Unit Price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: unitPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                prefixText: '\$ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Total
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'Total',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: totalController,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: '\$0',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Salesperson',
                    salespersons,
                    selectedSalesperson,
                    'Select Salesperson',
                    hasStaff
                        ? (value) => setState(() => selectedSalesperson = value)
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // 2-column row: Customer Name & Phone Number
                  Row(
                    children: [
                      // Customer Name (optional)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer Name',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: customerNameController,
                              decoration: InputDecoration(
                                hintText: 'Optional',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone Number (optional)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Optional',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Two buttons in column
            // Button 1: Record Sales (golden background with shopping cart icon)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasStock &&
                        hasStaff &&
                        selectedElectronicsType != null
                    ? () async {
                  if (selectedElectronicsType == null ||
                      selectedProductName == null ||
                      selectedModel == null ||
                      selectedSpecification == null ||
                      selectedSalesperson == null ||
                      quantityController.text.isEmpty ||
                      unitPriceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
                    );
                    return;
                  }
                    final matchingProduct = _selectedProduct(allProducts);
                    if (matchingProduct == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selected product combination does not match stock.')),
                      );
                      return;
                    }
                    final quantity = int.tryParse(quantityController.text) ?? 0;
                    final unitPrice = int.tryParse(unitPriceController.text) ?? 0;
                    if (quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quantity must be greater than zero.')),
                      );
                      return;
                    }
                    if (quantity > matchingProduct.stock) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Only ${matchingProduct.stock} unit(s) available in stock.',
                          ),
                        ),
                      );
                      return;
                    }

                    final sale = Sale(
                      id: DateTime.now().microsecondsSinceEpoch,
                      productId: matchingProduct.id,
                      productName: selectedProductName!,
                      salesperson: selectedSalesperson!,
                      quantity: quantity,
                      unitPrice: unitPrice,
                      total: quantity * unitPrice,
                      createdAt: DateTime.now(),
                      branchId: matchingProduct.branchId,
                    );

                    await ref.read(cashierDataProvider.notifier).recordSale(sale);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sale recorded successfully')),
                    );
                    context.go('/cashier-daily-sales');
                }
                    : null,
                icon: const Icon(Icons.shopping_cart, size: 20, color: Colors.black),
                label: const Text(
                  'Record Sales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Button 2: Close (white background, black/grey outline)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/cashier-dashboard'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade500, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}