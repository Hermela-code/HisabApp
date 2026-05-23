import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabapp/application/providers/cashier_data_provider.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_branchcost.dart';
import 'package:hisabapp/core/presentation/widgets/modals/delete.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class BranchCost extends ConsumerStatefulWidget {
  const BranchCost({super.key});

  @override
  ConsumerState<BranchCost> createState() => _BranchCostState();
}

class _BranchCostState extends ConsumerState<BranchCost> {
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _todayString();
  }

  String _todayString() => DateTime.now().toIso8601String().split('T').first;

  String _formatDisplayDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[1]}/${parts[2]}/${parts[0]}';
  }

  List<String> _availableDates(List<CashierCostRecord> allCosts) {
    final dates = <String>{_todayString()};
    for (final cost in allCosts) {
      dates.add(cost.date);
    }
    final sorted = dates.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

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

  void _showAddCostModal() {
    _showBlurModal(
      AddBranchCostModal(
        onAddCost: (description, amount) {
          ref.read(cashierDataProvider.notifier).addCost(
                description: description,
                amount: amount,
                date: _selectedDate,
              );
        },
      ),
    );
  }

  void _showDeleteModal(CashierCostRecord cost) {
    _showBlurModal(
      DeleteProductView(
        productName: cost.description,
        onDelete: () {
          ref.read(cashierDataProvider.notifier).removeCost(cost.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCosts = ref.watch(cashierDataProvider).costs;
    final dateOptions = _availableDates(allCosts);
    final effectiveDate =
        dateOptions.contains(_selectedDate) ? _selectedDate : dateOptions.first;
    final metrics = ref.watch(cashierDailyMetricsProvider(effectiveDate));

    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Branch Costs',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Track daily expenses',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: _showAddCostModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add Cost',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: effectiveDate,
                            isExpanded: true,
                            items: dateOptions
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(_formatDisplayDate(d)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedDate = value);
                              }
                            },
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
                    child: Column(
                      children: [
                        const Text('Total Costs', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(
                          metrics.formattedCosts,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (metrics.costRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No costs logged for ${_formatDisplayDate(effectiveDate)}. Tap Add Cost to record an expense.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              )
            else
              ...metrics.costRecords.asMap().entries.expand((entry) {
                final cost = entry.value;
                final isLast = entry.key == metrics.costRecords.length - 1;
                return [
                  _buildCostItem(cost, BranchFinance.formatMoney(cost.amount)),
                  if (!isLast) const SizedBox(height: 16),
                ];
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCostItem(CashierCostRecord cost, String amount) {
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
              Text(cost.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(cost.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                onPressed: () => _showDeleteModal(cost),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
