import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/models/daily_report.dart';
import 'package:hisabapp/application/providers/owner_exports_provider.dart';
import 'package:hisabapp/core/navigation/app_router.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class ExportArchivePage extends ConsumerStatefulWidget {
  const ExportArchivePage({super.key});

  @override
  ConsumerState<ExportArchivePage> createState() => _ExportArchivePageState();
}

class _ExportArchivePageState extends ConsumerState<ExportArchivePage> {
  String _searchQuery = '';

  List<DailyReportArchive> _filteredReports(List<DailyReportArchive> reports) {
    if (_searchQuery.isEmpty) return reports.reversed.toList();
    return reports
        .where((r) => r.date.contains(_searchQuery))
        .toList()
        .reversed
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(ownerExportsProvider).reports;
    final filtered = _filteredReports(reports);

    return OwnerLayout(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export / Archive',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 6),
            Opacity(
              opacity: 0.5,
              child: const Text(
                'Closed and archive daily reports',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search by date (YYYY-MM-DD)',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No exported reports yet. Use Export Today on a branch page.'
                              : 'No reports found for $_searchQuery',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => context.go(
                          AppRouter.ownerReport,
                          extra: ReportNavigationArgs(
                            report: filtered[i],
                            returnRoute: AppRouter.ownerExports,
                            source: ReportSource.owner,
                          ),
                        ),
                        child: _buildReportBox(filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportBox(DailyReportArchive report) {
    final status = report.isDeposited ? 'deposited' : 'pending';
    final statusColor = report.isDeposited ? Colors.green : Colors.amber;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.file_upload_outlined, size: 28, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      report.branchName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      report.formattedIncome,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    '${report.totalUnits} units • ${report.distinctProducts} products • -${report.formattedOperationalCost} cost',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status == 'pending' ? Icons.access_time : Icons.check_circle,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
