import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/models/daily_report.dart';
import 'package:hisabapp/application/providers/owner_exports_provider.dart';
import 'package:hisabapp/core/navigation/app_router.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_branch.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/domain/entities/branch.dart' as domain;

class BranchPage extends ConsumerStatefulWidget {
  const BranchPage({super.key});

  @override
  ConsumerState<BranchPage> createState() => _BranchPageState();
}

class _BranchPageState extends ConsumerState<BranchPage> {
  final List<Map<String, String>> _branches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final persisted = await ref.read(appRepositoryProvider).getBranches();
      if (!mounted) return;
      setState(() {
        _branches
          ..clear()
          ..addAll(persisted.map((b) => {
                'name': b.name,
                'location': b.location,
                'cashier': b.cashier,
              }));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAddBranchModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AddBranchView(
          onAddBranch: (branchName, location, cashierName) async {
            if (branchName.isEmpty) return;

            setState(() {
              _branches.add({
                'name': branchName,
                'location': location,
                'cashier': cashierName,
              });
            });

            try {
              final repository = ref.read(appRepositoryProvider);
              final persisted = await repository.getBranches();
              final nextId = persisted.isEmpty
                  ? 1
                  : persisted.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
              final newBranch = domain.Branch(
                id: nextId,
                name: branchName,
                companyId: 1,
                location: location,
                cashier: cashierName,
              );
              await repository.addBranch(newBranch);
              ref.read(ownerExportsProvider.notifier).saveBranchSession(
                    branchName,
                    OwnerBranchSession(
                      branchData: {
                        'name': branchName,
                        'location': location,
                        'cashier': cashierName,
                      },
                    ),
                  );
            } catch (_) {
              // UI already updated; persistence failure is non-blocking
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OwnerLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Branches', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 6),
            Opacity(
              opacity: 0.5,
              child: Text(
                _loading ? 'Loading branches...' : '${_branches.length} branches',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () => _showAddBranchModal(context),
              icon: const Icon(Icons.add, size: 18, color: Colors.black),
              label: const Text('Add Branch', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),

            if (!_loading && _branches.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No branches yet. Tap Add Branch to create one.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),

            for (var i = 0; i < _branches.length; i++) ...[
              _buildBranchCard(
                context,
                _branches[i]['name'] ?? '',
                _branches[i]['location'] ?? '',
                _branches[i]['cashier'] ?? '',
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  void _exportBranchToday(
    BuildContext context,
    String branchName,
    String locationText,
    String personCode,
  ) {
    final session = ref.read(ownerExportsProvider.notifier).sessionFor(branchName);
    if (session == null || (session.sales.isEmpty && session.products.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Open $branchName first to load branch activity.')),
      );
      context.go(
        '/branch-detail',
        extra: {'name': branchName, 'location': locationText, 'cashier': personCode},
      );
      return;
    }

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

  Widget _buildBranchCard(BuildContext context, String branchName, String locationText, String personCode) {
    return GestureDetector(
      onTap: () {
        final session = ref.read(ownerExportsProvider.notifier).sessionFor(branchName);
        context.go(
          '/branch-detail',
          extra: {
            'name': branchName,
            'location': locationText,
            'cashier': personCode,
            'products': session?.products ?? <Map<String, String>>[],
            'sales': session?.sales ?? <Map<String, String>>[],
            'costs': session?.costs ?? <Map<String, String>>[],
            'staff': session?.staff ?? <Map<String, String>>[],
          },
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.business, size: 42, color: Colors.grey.shade700),
            const SizedBox(height: 12),
            Text(branchName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 16),
            Opacity(
              opacity: 0.6,
              child: Row(children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationText.isNotEmpty ? locationText : 'No location set',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: 0.6,
              child: Row(children: [
                Icon(Icons.person, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    personCode.isNotEmpty ? personCode : 'No cashier assigned',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _exportBranchToday(context, branchName, locationText, personCode),
                icon: const Icon(Icons.file_upload, size: 18, color: Colors.black),
                label: const Text('Export today', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
