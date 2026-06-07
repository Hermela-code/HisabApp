import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/models/daily_report.dart';
import 'package:hisabapp/application/providers/cashier_data_provider.dart';
import 'package:hisabapp/application/providers/owner_exports_provider.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class ReportPage extends ConsumerStatefulWidget {
  final DailyReportArchive report;
  final String returnRoute;
  final ReportSource source;

  const ReportPage({
    super.key,
    required this.report,
    this.returnRoute = '/owner-exports',
    this.source = ReportSource.owner,
  });

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  late bool _isDeposited;

  @override
  void initState() {
    super.initState();
    _isDeposited = widget.report.isDeposited;
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(widget.returnRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(report.titleLabel, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => _close(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.branchName,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              children: widget.source == ReportSource.cashier
                  ? [
                      Expanded(
                        child: _buildSummaryBox(
                          title: 'Income',
                          amount: report.formattedIncome,
                          amountColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryBox(
                          title: 'Total Product',
                          amount: '${report.totalProductStock} units',
                          amountColor: Colors.black,
                        ),
                      ),
                    ]
                  : [
                      Expanded(
                        child: _buildSummaryBox(
                          title: 'Income',
                          amount: report.formattedIncome,
                          amountColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryBox(
                          title: 'Op. Cost',
                          amount: report.formattedOperationalCost,
                          amountColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSummaryBox(
                          title: 'Units',
                          amount: '${report.totalUnits}',
                          amountColor: Colors.black,
                        ),
                      ),
                    ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Product Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: report.productRows.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No product sales in this report.'),
                    )
                  : Column(
                      children: [
                        _buildTableHeader(
                          columns: ['Product', 'Model', 'SPEC', 'QTY', 'Revenue'],
                        ),
                        Divider(thickness: 1.5, color: Colors.grey.shade400, height: 0),
                        ...report.productRows.map(
                          (row) => _buildTableRow(
                            values: [
                              row.productName,
                              row.model,
                              row.specification,
                              '${row.quantity}',
                              BranchFinance.formatMoney(row.revenue),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sales by Staff',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: report.staffRows.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No staff sales in this report.'),
                    )
                  : Column(
                      children: [
                        _buildTableHeader(
                          columns: ['Staff', 'Product', 'Model', 'SPEC', 'QTY'],
                        ),
                        Divider(thickness: 1.5, color: Colors.grey.shade400, height: 0),
                        ...report.staffRows.map(
                          (row) => _buildTableRow(
                            values: [
                              row.staffName,
                              row.productName,
                              row.model,
                              row.specification,
                              '${row.quantity}',
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: report.toClipboardText(
                          cashierSummary: widget.source == ReportSource.cashier,
                        ),
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16, color: Colors.black),
                    label: const Text(
                      'Copy',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDeposited
                        ? null
                        : () {
                            if (widget.source == ReportSource.cashier) {
                              ref
                                  .read(cashierDataProvider.notifier)
                                  .markReportDeposited(report.id);
                            } else {
                              ref
                                  .read(ownerExportsProvider.notifier)
                                  .markDeposited(report.id);
                            }
                            setState(() => _isDeposited = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Marked as deposited'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                    icon: Icon(
                      _isDeposited ? Icons.check_circle : Icons.check_circle_outline,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isDeposited ? 'Deposited' : 'Mark Deposited',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox({
    required String title,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Text(title, style: const TextStyle(fontSize: 11, color: Colors.black)),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: amountColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader({required List<String> columns}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: columns
            .map(
              (col) => Expanded(
                child: Text(
                  col,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTableRow({required List<String> values}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: values
            .map(
              (val) => Expanded(
                child: Text(val, style: const TextStyle(fontSize: 11, color: Colors.black)),
              ),
            )
            .toList(),
      ),
    );
  }
}
