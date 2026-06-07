import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/application/mappers/branch_data_mapper.dart';
import 'package:hisabapp/application/models/daily_report.dart';
import 'package:hisabapp/application/providers/owner_exports_provider.dart';
import 'package:hisabapp/application/services/branch_persistence.dart';
import 'package:hisabapp/core/navigation/app_router.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_product.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_branchcost.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_staff.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_stock.dart';
import 'package:hisabapp/core/presentation/widgets/modals/update_product.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class BranchDetailPage extends ConsumerStatefulWidget {
  final Map<String, String> data;
  final List<Map<String, String>>? products;
  final List<Map<String, String>>? sales;
  final List<Map<String, String>>? costs;
  final List<Map<String, String>>? staff;
  final String? initialTab;

  const BranchDetailPage({
    super.key,
    required this.data,
    this.products,
    this.sales,
    this.costs,
    this.staff,
    this.initialTab,
  });

  @override
  ConsumerState<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends ConsumerState<BranchDetailPage> {
  String _activeTab = 'Stock';
  final List<String> _tabLabels = ['Stock', 'Sales', 'Costs', 'Staff'];

  final List<Map<String, String>> _products = [];
  final List<Map<String, String>> _sales = [];
  final List<Map<String, String>> _costs = [];
  final List<Map<String, String>> _staff = [];
  int _branchId = 0;
  bool _isLoading = true;

  int get _totalIncome => BranchFinance.totalIncome(_sales);
  int get _totalProductCost => BranchFinance.totalProductCost(_sales);
  int get _totalBranchExpenses => BranchFinance.totalBranchExpenses(_costs);
  int get _netProfit => BranchFinance.netProfit(sales: _sales, costs: _costs);

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null && _tabLabels.contains(widget.initialTab)) {
      _activeTab = widget.initialTab!;
    }
    if (widget.products != null) {
      _products.addAll(widget.products!.map((p) => Map<String, String>.from(p)));
      _sales.addAll((widget.sales ?? []).map((s) => Map<String, String>.from(s)));
      _costs.addAll((widget.costs ?? []).map((c) => Map<String, String>.from(c)));
      _staff.addAll((widget.staff ?? []).map((s) => Map<String, String>.from(s)));
      _enrichAllSales();
    }
    _loadFromRepository();
  }

  Future<void> _loadFromRepository() async {
    final repo = ref.read(appRepositoryProvider);
    final branchName = widget.data['name'] ?? '';
    if (branchName.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      _branchId = await BranchPersistence.resolveBranchId(repo, branchName);
      final session = await BranchPersistence.loadSession(
        repo,
        branchName,
        Map<String, String>.from(widget.data),
      );
      if (!mounted) return;
      setState(() {
        _products
          ..clear()
          ..addAll(session.products.map((p) => Map<String, String>.from(p)));
        _sales
          ..clear()
          ..addAll(session.sales.map((s) => Map<String, String>.from(s)));
        _costs
          ..clear()
          ..addAll(session.costs.map((c) => Map<String, String>.from(c)));
        _staff
          ..clear()
          ..addAll(session.staff.map((s) => Map<String, String>.from(s)));
        _enrichAllSales();
        _isLoading = false;
      });
      _syncOwnerSession();
    } catch (e) {
      debugPrint('Error loading branch details from repository: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _nextEntityId(List<Map<String, String>> items) {
    if (items.isEmpty) return 1;
    return items
            .map((item) => int.tryParse(item['id'] ?? '0') ?? 0)
            .fold(0, (a, b) => a > b ? a : b) +
        1;
  }

  void _syncOwnerSession() {
    final branchName = widget.data['name'] ?? '';
    if (branchName.isEmpty) return;
    ref.read(ownerExportsProvider.notifier).saveBranchSession(
          branchName,
          OwnerBranchSession(
            branchData: Map<String, String>.from(widget.data),
            products: _products.map((p) => Map<String, String>.from(p)).toList(),
            sales: _sales.map((s) => Map<String, String>.from(s)).toList(),
            costs: _costs.map((c) => Map<String, String>.from(c)).toList(),
            staff: _staff.map((s) => Map<String, String>.from(s)).toList(),
          ),
        );
  }

  void _exportToday() {
    _syncOwnerSession();
    final branchName = widget.data['name'] ?? 'Branch';
    final report = ref.read(ownerExportsProvider.notifier).exportBranchToday(branchName);
    context.go(
      AppRouter.ownerReport,
      extra: ReportNavigationArgs(
        report: report,
        returnRoute: AppRouter.ownerExports,
        source: ReportSource.owner,
      ),
    );
  }

  void _enrichAllSales() {
    for (var i = 0; i < _sales.length; i++) {
      _sales[i] = BranchFinance.enrichSale(_sales[i], _products);
    }
  }

  Map<String, dynamic> _branchNavigationExtra() => {
        'branch': widget.data,
        'products': _products.map((p) => Map<String, String>.from(p)).toList(),
        'sales': _sales.map((s) => Map<String, String>.from(s)).toList(),
        'costs': _costs.map((c) => Map<String, String>.from(c)).toList(),
        'staff': _staff.map((s) => Map<String, String>.from(s)).toList(),
      };

  IconData _tabIcon(String label) {
    switch (label) {
      case 'Stock': return Icons.inventory_2_outlined;
      case 'Sales': return Icons.attach_money;
      case 'Costs': return Icons.money_off;
      case 'Staff': return Icons.people_outline;
      default: return Icons.circle;
    }
  }

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

  void _showAddProductModal(BuildContext context) {
    _showBlurModal(context, AddProductView(onAddProduct: (category, name, model, spec, sellingPrice, costPrice, totalStock, remainingStock) async {
      final id = _nextEntityId(_products);
      final map = {
        'id': id.toString(),
        'name': name,
        'brand': model,
        'mobile': category,
        'spec': spec,
        'price': sellingPrice.toString(),
        'cost_price': costPrice.toString(),
        'units': (remainingStock > 0 ? remainingStock : totalStock).toString(),
      };
      final product = BranchDataMapper.productFromMap(map, id, _branchId);
      await BranchPersistence.persistProduct(ref.read(appRepositoryProvider), product);
      if (!context.mounted) return;
      setState(() {
        _products.add(map);
        _syncOwnerSession();
      });
    }));
  }

  void _showEditProductModal(BuildContext context, int index) {
    final p = _products[index];
    _showBlurModal(context, UpdateProductView(
      initialName: p['name'],
      initialModel: p['brand'],
      initialSpecification: p['spec'],
      initialSellingPrice: int.tryParse(p['price'] ?? ''),
      initialCostPrice: int.tryParse(p['cost_price'] ?? ''),
      initialStock: int.tryParse(p['units'] ?? ''),
      onUpdate: (name, model, spec, sellingPrice, costPrice, stock) async {
        final id = int.tryParse(p['id'] ?? '') ?? index + 1;
        final map = {
          'id': id.toString(),
          'name': name,
          'brand': model,
          'mobile': p['mobile'] ?? 'Product',
          'spec': spec,
          'price': sellingPrice.toString(),
          'cost_price': costPrice.toString(),
          'units': stock.toString(),
        };
        final product = BranchDataMapper.productFromMap(map, id, _branchId);
        await BranchPersistence.persistProduct(ref.read(appRepositoryProvider), product);
        if (!context.mounted) return;
        setState(() {
          _products[index] = map;
          _syncOwnerSession();
        });
      },
    ));
  }

  void _showAddStockModal(BuildContext context, int index) {
    final currentProduct = _products[index];
    _showBlurModal(context, AddStockScreen(onAddStock: (unitsToAdd, newSellingPrice, newCostPrice) async {
      final currentUnits = int.tryParse(currentProduct['units'] ?? '0') ?? 0;
      final updatedUnits = currentUnits + unitsToAdd;
      currentProduct['units'] = updatedUnits.toString();
      if (newSellingPrice != null && newSellingPrice > 0) {
        currentProduct['price'] = newSellingPrice.toString();
      }
      if (newCostPrice != null && newCostPrice > 0) {
        currentProduct['cost_price'] = newCostPrice.toString();
      }
      final id = int.tryParse(currentProduct['id'] ?? '') ?? index + 1;
      final product = BranchDataMapper.productFromMap(currentProduct, id, _branchId);
      await BranchPersistence.persistProduct(ref.read(appRepositoryProvider), product);
      if (!context.mounted) return;
      setState(() => _syncOwnerSession());
    }, currentStock: int.tryParse(currentProduct['units'] ?? '0') ?? 0));
  }

  void _showAddCostModal(BuildContext context) {
    _showBlurModal(context, AddBranchCostModal(onAddCost: (description, amount) async {
      final id = _nextEntityId(_costs);
      final map = {
        'id': id.toString(),
        'description': description,
        'date': DateTime.now().toIso8601String().split('T').first,
        'amount': amount.toString(),
      };
      final cost = BranchDataMapper.costFromMap(map, id, _branchId);
      await BranchPersistence.persistCost(ref.read(appRepositoryProvider), cost);
      if (!context.mounted) return;
      setState(() {
        _costs.add(map);
        _syncOwnerSession();
      });
    }));
  }

  void _showAddStaffModal(BuildContext context) {
    _showBlurModal(context, AddStaffView(onAddStaff: (name, phoneNumber) async {
      final id = _nextEntityId(_staff);
      final map = {
        'id': id.toString(),
        'name': name,
        'phone': phoneNumber,
        'units': '0 units',
        'products': '',
      };
      final staff = BranchDataMapper.staffFromMap(map, id, _branchId);
      await BranchPersistence.persistStaff(ref.read(appRepositoryProvider), staff);
      if (!context.mounted) return;
      setState(() {
        _staff.add(map);
        _syncOwnerSession();
      });
    }));
  }

  void _showRecordSaleModal(BuildContext context) {
    context.go(AppRouter.ownerRecordSale, extra: _branchNavigationExtra());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const OwnerLayout(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return OwnerLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.data['name'] ?? 'Branch', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 6),
            Opacity(
              opacity: 0.5,
              child: Text(widget.data['location'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportToday,
                icon: const Icon(Icons.file_upload_outlined, size: 18, color: Colors.black),
                label: const Text(
                  'Export Today',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Net Profit Engine
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NET PROFIT Engine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _buildMetricCard('Income', BranchFinance.formatMoney(_totalIncome), Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Product Cost', BranchFinance.formatMoney(_totalProductCost), Colors.red)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildMetricCard('Branch Expenses', BranchFinance.formatMoney(_totalBranchExpenses), Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Net Profit',
                        BranchFinance.formatMoney(_netProfit),
                        _netProfit >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _tabLabels.map((label) => GestureDetector(
                onTap: () => setState(() => _activeTab = label),
                child: _buildTabChip(label, _activeTab == label),
              )).toList(),
            ),
            const SizedBox(height: 16),

            _buildTabContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade200,
        border: Border.all(color: isActive ? Colors.amber.shade700 : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_tabIcon(label), size: 14, color: isActive ? Colors.amber.shade700 : Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
              color: isActive ? Colors.amber.shade700 : Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_activeTab) {
      case 'Stock': return _buildStockTab(context);
      case 'Sales': return _buildSalesTab(context);
      case 'Costs': return _buildCostsTab(context);
      case 'Staff': return _buildStaffTab(context);
      default: return const SizedBox.shrink();
    }
  }

  // ── STOCK ──────────────────────────────────────────────
  Widget _buildStockTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showAddProductModal(context),
            icon: const Icon(Icons.add, size: 18, color: Colors.black),
            label: const Text('Add Product', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No stock items yet for ${widget.data['name'] ?? 'this branch'}.', style: TextStyle(color: Colors.grey.shade600))),
          ),
        ..._products.asMap().entries.map((entry) {
          final index = entry.key;
          final p = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC4F8C1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${p['units'] ?? '0'} units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSpecLabel('Brand', p['brand'] ?? ''),
                      const SizedBox(width: 16),
                      _buildSpecLabel('Category', p['mobile'] ?? ''),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSpecLabel('Specification', p['spec'] ?? ''),
                      const SizedBox(width: 16),
                      _buildSpecLabel('Selling Price', '\$${p['price'] ?? '0'}'),
                      const SizedBox(width: 16),
                      _buildSpecLabel('Cost Price', '\$${p['cost_price'] ?? '0'}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddStockModal(context, index),
                          icon: const Icon(Icons.add, size: 14, color: Colors.white),
                          label: const Text('Add Stock', style: TextStyle(fontSize: 12, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showEditProductModal(context, index),
                        icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade600),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final id = int.tryParse(p['id'] ?? '') ?? index + 1;
                          await BranchPersistence.deleteProduct(
                            ref.read(appRepositoryProvider),
                            id,
                          );
                          if (!context.mounted) return;
                          setState(() {
                            _products.removeAt(index);
                            _syncOwnerSession();
                          });
                        },
                        icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSpecLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── SALES ──────────────────────────────────────────────
  Widget _buildSalesTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showRecordSaleModal(context),
            icon: const Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.black),
            label: const Text('Record sale', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_sales.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No sales recorded for ${widget.data['name'] ?? 'this branch'}.', style: TextStyle(color: Colors.grey.shade600))),
          ),
        if (_sales.isNotEmpty)
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
                children: ['DATE', 'Product', 'SALESPERSON', 'QTY'].map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(h, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                )).toList(),
              ),
              ..._sales.map((s) => TableRow(
                children: [s['date']!, s['product']!, s['salesperson']!, s['qty']!].map((v) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(v, style: const TextStyle(fontSize: 13)),
                )).toList(),
              )),
            ],
          ),
      ],
    );
  }

  // ── COSTS ──────────────────────────────────────────────
  Widget _buildCostsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showAddCostModal(context),
            icon: const Icon(Icons.add, size: 18, color: Colors.black),
            label: const Text('Add Cost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_costs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No costs logged yet for ${widget.data['name'] ?? 'this branch'}.', style: TextStyle(color: Colors.grey.shade600))),
          ),
        ..._costs.map((c) => Column(
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c['description'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(c['date'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ]),
                  Text('\$${c['amount'] ?? '0'}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                ],
              ),
            ),
          ],
        )).toList(),
      ],
    );
  }

  // ── STAFF ──────────────────────────────────────────────
  Widget _buildStaffTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showAddStaffModal(context),
            icon: const Icon(Icons.add, size: 18, color: Colors.black),
            label: const Text('Add Staff', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_staff.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No staff added yet for ${widget.data['name'] ?? 'this branch'}.', style: TextStyle(color: Colors.grey.shade600))),
          ),
        ..._staff.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(s['phone'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Text(s['units'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    if ((s['products'] ?? '').isNotEmpty)
                      ...((s['products'] ?? '').split(',')).map((p) => Text(p.trim(), style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final id = int.tryParse(s['id'] ?? '') ?? 0;
                  if (id > 0) {
                    await BranchPersistence.deleteStaff(
                      ref.read(appRepositoryProvider),
                      id,
                    );
                  }
                  if (!context.mounted) return;
                  setState(() {
                    _staff.remove(s);
                    _syncOwnerSession();
                  });
                },
                icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMetricCard(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: amountColor)),
      ]),
    );
  }
}
