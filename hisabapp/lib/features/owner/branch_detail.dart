import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_product.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_branchcost.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_staff.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_stock.dart';

class GoroDetailPage extends StatefulWidget {
  const GoroDetailPage({super.key});

  @override
  State<GoroDetailPage> createState() => _GoroDetailPageState();
}

class _GoroDetailPageState extends State<GoroDetailPage> {
  String _activeTab = 'Stock';
  final List<String> _tabLabels = ['Stock', 'Sales', 'Costs', 'Staff'];

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

  @override
  Widget build(BuildContext context) {
    return OwnerLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goro', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 6),
            Opacity(
              opacity: 0.5,
              child: const Text('Goro, Addis Ababa', style: TextStyle(fontSize: 16, color: Colors.black)),
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
                    Expanded(child: _buildMetricCard('Income', '\$340,000', Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Product Cost', '\$945,000', Colors.red)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildMetricCard('Branch Expenses', '\$340,000', Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Net Profit', '-\$607,200', Colors.red)),
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
    final products = [
      {'name': 'Camon-20', 'brand': 'Tecno', 'mobile': 'Mobile', 'spec': '256/8', 'price': '\$20,000', 'units': '20'},
      {'name': 'iPhone-17', 'brand': 'Apple', 'mobile': 'Mobile', 'spec': '512/16', 'price': '\$50,000', 'units': '10'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showBlurModal(context, const AddProductView()),
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
        ...products.map((p) => Padding(
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
                    Text(p['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC4F8C1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${p['units']} units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSpecLabel('Electronics', p['brand']!),
                    const SizedBox(width: 16),
                    _buildSpecLabel('Product', p['mobile']!),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildSpecLabel('Specification', p['spec']!),
                    const SizedBox(width: 16),
                    _buildSpecLabel('Selling Price', p['price']!),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showBlurModal(context, const AddStockScreen()),
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
                      onPressed: () {},
                      icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade600),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )).toList(),
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
    final sales = [
      {'date': '2026-04-08', 'product': 'Techno', 'salesperson': 'Helen', 'qty': '2'},
      {'date': '2026-04-08', 'product': 'iPhone', 'salesperson': 'Helen', 'qty': '1'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/owner-record-sale'),
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
            ...sales.map((s) => TableRow(
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
    final costs = [
      {'name': 'Copy', 'date': '2026-04-08', 'amount': '\$200'},
      {'name': 'Transport', 'date': '2026-04-08', 'amount': '\$2000'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showBlurModal(context, Dialog(
              backgroundColor: Colors.transparent,
              child: const AddBranchCostModal(),
            )),
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
        ...costs.map((c) => Column(
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c['name']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(c['date']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ]),
                  Text(c['amount']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
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
    final staff = [
      {
        'name': 'Samuel Girma',
        'phone': '+251907654321',
        'units': '15 units',
        'products': ['.camon 20 - 5', '.iphone 12 - 10'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showBlurModal(context, const AddStaffView()),
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
        ...staff.map((s) => Container(
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
                    Text(s['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(s['phone'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Text(s['units'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    ...(s['products'] as List<String>).map((p) =>
                      Text(p, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
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
