import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/models/daily_report.dart';
import 'package:hisabapp/application/providers/cashier_data_provider.dart';
import 'package:hisabapp/core/navigation/app_router.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class ExportArchive extends ConsumerStatefulWidget {
  const ExportArchive({super.key});

  @override
  ConsumerState<ExportArchive> createState() => _ExportArchiveState();
}

class _ExportArchiveState extends ConsumerState<ExportArchive> {
  String _searchQuery = '';

  List<DailyReportArchive> _filteredReports(List<DailyReportArchive> reports) {
    if (_searchQuery.isEmpty) return reports.reversed.toList();
    return reports
        .where((r) => r.date.contains(_searchQuery))
        .toList()
        .reversed
        .toList();
  }

  void _exportToday() {
    final today = DateTime.now().toIso8601String().split('T').first;
    final daySales = ref.read(cashierDataProvider).salesForDate(today);
    if (daySales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sales recorded today. Record sales on Daily Sales first.'),
        ),
      );
      return;
    }

    final report = ref.read(cashierDataProvider.notifier).exportToday(date: today);
    context.go(
      AppRouter.ownerReport,
      extra: ReportNavigationArgs(
        report: report,
        returnRoute: AppRouter.cashierExportArchive,
        source: ReportSource.cashier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(cashierDataProvider).exportedReports;
    final filtered = _filteredReports(reports);

    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export / Archive',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Close and archive daily reports',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: _exportToday,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: const Text(
                  'Export Today',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black54),
                  hintText: 'Search by date (yyyy-mm-dd)...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
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
                    'No archived reports yet. Tap Export Today after recording daily sales.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              )
            else
              ...filtered.map(
                (report) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildArchiveCard(context, report),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveCard(BuildContext context, DailyReportArchive report) {
    final status = report.isDeposited ? 'Deposited' : 'Pending';
    final statusColor = report.isDeposited ? Colors.green : Colors.amber;
    final unitsLabel =
        '${report.totalUnits} units · ${report.distinctProducts} products';

    return GestureDetector(
      onTap: () => context.go(
        AppRouter.ownerReport,
        extra: ReportNavigationArgs(
          report: report,
          returnRoute: AppRouter.cashierExportArchive,
          source: ReportSource.cashier,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history, color: Colors.black54, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.date,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(unitsLabel, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(
                    '${report.totalProductStock} units in stock',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  report.formattedIncome,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        report.isDeposited ? Icons.check_circle_outline : Icons.access_time,
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
