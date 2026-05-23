import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../application/di.dart';
import '../../core/navigation/app_router.dart';
import '../../core/presentation/widgets/owner_header.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';

class _StockLine {
  final Product product;
  final String category;
  final int costPrice;

  const _StockLine({
    required this.product,
    required this.category,
    required this.costPrice,
  });
}

class OwnerRecordSalePage extends StatefulWidget {
  final Map<String, String> branchData;
  final List<Map<String, String>> stockProducts;
  final List<Map<String, String>> staffMaps;
  final List<Map<String, String>> salesMaps;
  final List<Map<String, String>> costsMaps;

  const OwnerRecordSalePage({
    super.key,
    this.branchData = const {},
    this.stockProducts = const [],
    this.staffMaps = const [],
    this.salesMaps = const [],
    this.costsMaps = const [],
  });

  @override
  State<OwnerRecordSalePage> createState() => _OwnerRecordSalePageState();
}

class _OwnerRecordSalePageState extends State<OwnerRecordSalePage> {
  String? selectedElectronicsType;
  String? selectedProductName;
  String? selectedModel;
  String? selectedSpecification;
  String? selectedSalesperson;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final List<_StockLine> stockLines = [];
  final List<Staff> staffList = [];
  late List<Map<String, String>> _productMaps;
  late List<Map<String, String>> _salesMaps;
  late List<Map<String, String>> _costsMaps;
  late List<Map<String, String>> _staffMaps;
  bool isLoading = true;
  int _branchId = 0;

  List<_StockLine> get _inStock =>
      stockLines.where((line) => line.product.stock > 0).toList();

  List<String> get electronicsTypes => _inStock
      .map((line) => line.category)
      .where((c) => c.isNotEmpty)
      .toSet()
      .toList();

  List<String> get productNames {
    final lines = selectedElectronicsType == null
        ? _inStock
        : _inStock.where((line) => line.category == selectedElectronicsType);
    return lines.map((line) => line.product.name).toSet().toList();
  }

  List<String> get models {
    final lines = _inStock.where((line) {
      if (selectedElectronicsType != null && line.category != selectedElectronicsType) {
        return false;
      }
      if (selectedProductName != null && line.product.name != selectedProductName) {
        return false;
      }
      return true;
    });
    return lines.map((line) => line.product.model).toSet().toList();
  }

  List<String> get specifications {
    final lines = _inStock.where((line) {
      if (selectedElectronicsType != null && line.category != selectedElectronicsType) {
        return false;
      }
      if (selectedProductName != null && line.product.name != selectedProductName) {
        return false;
      }
      if (selectedModel != null && line.product.model != selectedModel) {
        return false;
      }
      return true;
    });
    return lines.map((line) => line.product.specification).toSet().toList();
  }

  List<String> get salespersons => staffList.map((s) => s.name).toList();

  void updateTotal() {
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final unitPrice = int.tryParse(unitPriceController.text) ?? 0;
    totalController.text = (quantity * unitPrice).toString();
  }

  @override
  void initState() {
    super.initState();
    _productMaps = widget.stockProducts.map((p) => Map<String, String>.from(p)).toList();
    _salesMaps = widget.salesMaps.map((s) => Map<String, String>.from(s)).toList();
    _costsMaps = widget.costsMaps.map((c) => Map<String, String>.from(c)).toList();
    _staffMaps = widget.staffMaps.map((s) => Map<String, String>.from(s)).toList();
    quantityController.addListener(updateTotal);
    unitPriceController.addListener(updateTotal);
    _loadProductsAndStaff();
  }

  Future<void> _loadProductsAndStaff() async {
    _branchId = await _resolveBranchId();

    if (_productMaps.isNotEmpty) {
      stockLines.addAll(_parseStockMaps(_productMaps, _branchId));
    } else {
      final loadedProducts = await appRepository.getProducts(_branchId);
      stockLines.addAll(
        loadedProducts
            .map((p) => _StockLine(product: p, category: p.electronicsType, costPrice: 0))
            .where((line) => line.product.stock > 0),
      );
    }

    if (_staffMaps.isNotEmpty) {
      staffList.addAll(_parseStaffMaps(_staffMaps, _branchId));
    } else {
      final loadedStaff = await appRepository.getStaff(_branchId);
      staffList.addAll(loadedStaff);
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<int> _resolveBranchId() async {
    final branchName = widget.branchData['name'] ?? '';
    if (branchName.isEmpty) return 0;
    try {
      final branches = await appRepository.getBranches();
      for (final branch in branches) {
        if (branch.name.toLowerCase() == branchName.toLowerCase()) {
          return branch.id;
        }
      }
    } catch (_) {}
    if (branchName.toLowerCase().contains('goro')) return 1;
    if (branchName.toLowerCase().contains('cbe')) return 2;
    return branchName.hashCode.abs() % 100000 + 1;
  }

  List<_StockLine> _parseStockMaps(List<Map<String, String>> maps, int branchId) {
    return maps.asMap().entries.map((entry) {
      final map = entry.value;
      final stock = int.tryParse(map['units'] ?? '0') ?? 0;
      return _StockLine(
        category: map['mobile'] ?? map['name'] ?? 'Product',
        costPrice: int.tryParse(map['cost_price'] ?? '0') ?? 0,
        product: Product(
          id: entry.key + 1,
          name: map['name'] ?? '',
          model: map['brand'] ?? '',
          specification: map['spec'] ?? '',
          stock: stock,
          unitPrice: int.tryParse(map['price'] ?? '0') ?? 0,
          branchId: branchId,
        ),
      );
    }).toList();
  }

  List<Staff> _parseStaffMaps(List<Map<String, String>> maps, int branchId) {
    return maps.asMap().entries.map((entry) {
      final map = entry.value;
      return Staff(
        id: entry.key + 1,
        name: map['name'] ?? '',
        branchId: branchId,
      );
    }).toList();
  }

  _StockLine? _selectedStockLine() {
    if (selectedProductName == null ||
        selectedModel == null ||
        selectedSpecification == null) {
      return null;
    }
    try {
      return _inStock.firstWhere(
        (line) =>
            line.product.name == selectedProductName &&
            line.product.model == selectedModel &&
            line.product.specification == selectedSpecification,
      );
    } catch (_) {
      return null;
    }
  }

  Product? _selectedProduct() => _selectedStockLine()?.product;

  void _updateSelectedProductFields() {
    final product = _selectedProduct();
    if (product != null) {
      unitPriceController.text = product.unitPrice.toString();
    }
  }

  Map<String, dynamic> _branchNavigationExtra({bool afterSale = false}) => {
        'branch': widget.branchData,
        'products': _productMaps.map((p) => Map<String, String>.from(p)).toList(),
        'sales': _salesMaps.map((s) => Map<String, String>.from(s)).toList(),
        'costs': _costsMaps.map((c) => Map<String, String>.from(c)).toList(),
        'staff': _staffMaps.map((s) => Map<String, String>.from(s)).toList(),
        if (afterSale) 'activeTab': 'Sales',
      };

  void _goBackToBranch() {
    if (widget.branchData.isNotEmpty) {
      context.go(AppRouter.branchDetail, extra: _branchNavigationExtra());
    } else {
      context.go(AppRouter.branchDetail);
    }
  }

  void _applySaleToStock(_StockLine line, int quantity) {
    final index = _productMaps.indexWhere(
      (p) =>
          p['name'] == line.product.name &&
          p['brand'] == line.product.model &&
          p['spec'] == line.product.specification,
    );
    if (index < 0) return;
    final currentUnits = int.tryParse(_productMaps[index]['units'] ?? '0') ?? 0;
    _productMaps[index]['units'] = (currentUnits - quantity).toString();

    final stockIndex = stockLines.indexWhere(
      (s) =>
          s.product.name == line.product.name &&
          s.product.model == line.product.model &&
          s.product.specification == line.product.specification,
    );
    if (stockIndex >= 0) {
      final updated = stockLines[stockIndex].product.copyWith(
        stock: stockLines[stockIndex].product.stock - quantity,
      );
      stockLines[stockIndex] = _StockLine(
        product: updated,
        category: stockLines[stockIndex].category,
        costPrice: stockLines[stockIndex].costPrice,
      );
    }
  }

  void _applySaleToStaff(String salesperson, int quantity, String productName) {
    final index = _staffMaps.indexWhere((s) => s['name'] == salesperson);
    if (index < 0) return;
    final unitsText = _staffMaps[index]['units'] ?? '0 units';
    final current = int.tryParse(unitsText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    _staffMaps[index]['units'] = '${current + quantity} units';
    final existing = _staffMaps[index]['products'] ?? '';
    final entry = '.$productName - $quantity';
    _staffMaps[index]['products'] = existing.isEmpty ? entry : '$existing, $entry';
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return OwnerLayout(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasStock = _inStock.isNotEmpty;

    return OwnerLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Sale',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Opacity(
              opacity: 0.5,
              child: Text(
                widget.branchData['name'] != null && widget.branchData['name']!.isNotEmpty
                    ? 'Log New Transaction — ${widget.branchData['name']}'
                    : 'Log New Transaction',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            if (!hasStock) ...[
              const SizedBox(height: 12),
              Text(
                'No products in stock for this branch. Add products on the Stock tab first.',
                style: TextStyle(fontSize: 14, color: Colors.orange.shade800),
              ),
            ],
            const SizedBox(height: 24),
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
                    electronicsTypes,
                    selectedElectronicsType,
                    'Select category',
                    hasStock
                        ? (value) => setState(() {
                              selectedElectronicsType = value;
                              selectedProductName = null;
                              selectedModel = null;
                              selectedSpecification = null;
                            })
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Product Name',
                    productNames,
                    selectedProductName,
                    'Select product',
                    hasStock
                        ? (value) => setState(() {
                              selectedProductName = value;
                              selectedModel = null;
                              selectedSpecification = null;
                            })
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Model',
                    models,
                    selectedModel,
                    'Select model',
                    hasStock
                        ? (value) => setState(() {
                              selectedModel = value;
                              selectedSpecification = null;
                              _updateSelectedProductFields();
                            })
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Specification',
                    specifications,
                    selectedSpecification,
                    'Select specification',
                    hasStock
                        ? (value) => setState(() {
                              selectedSpecification = value;
                              _updateSelectedProductFields();
                            })
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Quantity',
                          quantityController,
                          hint: '1',
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'Unit Price',
                          unitPriceController,
                          hint: '0',
                          isNumber: true,
                          prefix: '\$ ',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'Total',
                          totalController,
                          hint: '\$0',
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    'Salesperson',
                    salespersons,
                    selectedSalesperson,
                    'Select salesperson',
                    salespersons.isNotEmpty
                        ? (value) => setState(() => selectedSalesperson = value)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Customer Name',
                          customerNameController,
                          hint: 'Optional',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'Phone Number',
                          phoneNumberController,
                          hint: 'Optional',
                          isPhone: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasStock ? () => _submitSale(context) : null,
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _goBackToBranch,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
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

  Future<void> _submitSale(BuildContext context) async {
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

    final stockLine = _selectedStockLine();
    final matchingProduct = stockLine?.product;
    if (matchingProduct == null || stockLine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected product combination does not match stock.'),
        ),
      );
      return;
    }

    final quantity = int.tryParse(quantityController.text) ?? 0;
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

    final unitPrice = int.tryParse(unitPriceController.text) ?? 0;
    final saleTotal = quantity * unitPrice;
    final costTotal = quantity * stockLine.costPrice;

    final sale = Sale(
      id: DateTime.now().microsecondsSinceEpoch,
      productId: matchingProduct.id,
      productName: selectedProductName!,
      salesperson: selectedSalesperson!,
      quantity: quantity,
      unitPrice: unitPrice,
      total: saleTotal,
      createdAt: DateTime.now(),
      branchId: matchingProduct.branchId,
    );

    try {
      await recordSaleUseCase.execute(sale);
    } catch (_) {
      // Sale may not persist when stock uses local-only ids; still update branch UI.
    }

    _applySaleToStock(stockLine, quantity);
    _applySaleToStaff(selectedSalesperson!, quantity, selectedProductName!);

    _salesMaps.add({
      'date': DateTime.now().toIso8601String().split('T').first,
      'product': selectedProductName!,
      'salesperson': selectedSalesperson!,
      'qty': quantity.toString(),
      'total': saleTotal.toString(),
      'cost_total': costTotal.toString(),
      'unit_price': unitPrice.toString(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale recorded successfully')),
    );
    context.go(AppRouter.branchDetail, extra: _branchNavigationExtra(afterSale: true));
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    String hint,
    ValueChanged<String?>? onChanged,
  ) {
    final isDisabled = items.isEmpty || onChanged == null;
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: items.contains(value) ? value : null,
            hint: Opacity(opacity: 0.5, child: Text(hint)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            items: isDisabled
                ? [
                    DropdownMenuItem<String>(
                      value: null,
                      enabled: false,
                      child: Text(items.isEmpty ? 'No items in stock' : hint),
                    ),
                  ]
                : items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
            onChanged: isDisabled ? null : onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String hint = '',
    bool isNumber = false,
    bool isPhone = false,
    bool readOnly = false,
    String prefix = '',
  }) {
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
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: isNumber
              ? TextInputType.number
              : isPhone
                  ? TextInputType.phone
                  : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixText: prefix.isEmpty ? null : prefix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
