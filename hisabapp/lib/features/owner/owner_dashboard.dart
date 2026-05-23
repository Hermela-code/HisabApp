import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/application/providers/owner_exports_provider.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';
import 'package:hisabapp/features/owner/branch_finance.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _branchCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final branches = await ref.read(appRepositoryProvider).getBranches();
      if (!mounted) return;
      setState(() {
        _branchCount = branches.length;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _aggregateIncome() {
    var total = 0;
    for (final session in ref.read(ownerExportsProvider).branchSessions.values) {
      total += BranchFinance.totalIncome(session.sales);
    }
    return total;
  }

  int _aggregateCosts() {
    var total = 0;
    for (final session in ref.read(ownerExportsProvider).branchSessions.values) {
      total += BranchFinance.totalBranchExpenses(session.costs);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ownerExportsProvider);
    final income = _aggregateIncome();
    final opCosts = _aggregateCosts();
    final net = income - opCosts;

    return OwnerLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Owner Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Global Business Overview',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              children: [
                _buildStatTile(
                  'BRANCHES',
                  _loading ? '...' : '$_branchCount',
                  const Icon(Icons.business, color: Color(0xFF3B82F6)),
                ),
                _buildStatTile(
                  'Total income',
                  BranchFinance.formatMoney(income),
                  const Icon(Icons.trending_up, color: Color(0xFF4CAF50)),
                ),
                _buildStatTile(
                  'OP. Costs',
                  BranchFinance.formatMoney(opCosts),
                  const Icon(Icons.money_off, color: Color(0xFFE57373)),
                ),
                _buildStatTile(
                  'NET/EST.',
                  BranchFinance.formatMoney(net),
                  const Icon(Icons.account_balance_wallet, color: Color(0xFF2196F3)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildBranchesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Widget icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              icon,
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Branches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              _loading
                  ? 'Loading branches...'
                  : _branchCount == 0
                      ? 'No branches yet. Open Branches to add one.'
                      : '$_branchCount branch(es) registered. Open Branches for details.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          if (!_loading && _branchCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/owner-branches'),
                  child: const Text('Manage branches'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
