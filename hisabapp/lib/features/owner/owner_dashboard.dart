import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Owner Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
=======
=======
import 'package:flutter_riverpod/flutter_riverpod.dart';
>>>>>>> 59d55fcba04bce7f95ca55415c0a89b7836e322e
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/application/providers/owner_exports_provider.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';
<<<<<<< HEAD
>>>>>>> 7d61e33541ea3ec1296aea576db4b7f8608ecfc8
=======
import 'package:hisabapp/features/owner/branch_finance.dart';
>>>>>>> 59d55fcba04bce7f95ca55415c0a89b7836e322e

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

  int _aggregateProductCosts() {
    var total = 0;
    for (final session in ref.read(ownerExportsProvider).branchSessions.values) {
      total += BranchFinance.totalProductCost(session.sales);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
<<<<<<< HEAD
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Owner Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              // Subheader with lower opacity
              const Text(
                'Global Business Overview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // 4 Boxes - 2 rows, 2 columns
              Row(
                children: [
                  Expanded(child: _buildMetricBox1()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricBox2()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMetricBox3()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricBox4()),
                ],
              ),
              const SizedBox(height: 32),

              // Branches section with outline
              _buildBranchesSection(),
            ],
          ),
=======
=======
    ref.watch(ownerExportsProvider);
    final income = _aggregateIncome();
    final opCosts = _aggregateCosts();
    final productCosts = _aggregateProductCosts();
    final net = income - opCosts - productCosts;

>>>>>>> 59d55fcba04bce7f95ca55415c0a89b7836e322e
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
>>>>>>> 7d61e33541ea3ec1296aea576db4b7f8608ecfc8
        ),
      ),
    );
  }

<<<<<<< HEAD
  // Box 1: BRANCHES - 2
  Widget _buildMetricBox1() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Column 1: Text and number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BRANCHES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '2',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          // Column 2: Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business,
              color: Color(0xFF3B82F6),
              size: 32,
            ),
=======
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
>>>>>>> 7d61e33541ea3ec1296aea576db4b7f8608ecfc8
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // Box 2: Total income - $240,000 with green growing icon
  Widget _buildMetricBox2() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Column 1: Text and number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total income',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '\$240,000',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          // Column 2: Green growing icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Colors.green,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // Box 3: OP. Costes - $0
  Widget _buildMetricBox3() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Column 1: Text and number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'OP. Costes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '\$0',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // Box 4: NET/EST. - $139,600 with BLUE growing icon
  Widget _buildMetricBox4() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Column 1: Text and number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NET/EST.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '\$139,600',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          // Column 2: Blue growing icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Colors.blue,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // Branches section with outline and two branch components
  Widget _buildBranchesSection() {
=======
  Widget _buildBranchesSection(BuildContext context) {
>>>>>>> 7d61e33541ea3ec1296aea576db4b7f8608ecfc8
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
<<<<<<< HEAD
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
=======
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
>>>>>>> 7d61e33541ea3ec1296aea576db4b7f8608ecfc8
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
<<<<<<< HEAD
            child: Text(
              'Branches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          // First branch component - GORO 
          _buildBranchItem(
            icon: Icons.business,
            title: 'GORO',
            subtitle: 'GORO, Addis Ababa',
            backgroundColor: const Color(0xFFF5F3FF), 
          ),
          const SizedBox(height: 8), // Gap between components
          // Second branch component - CBE (light purple/gray background)
          _buildBranchItem(
            icon: Icons.business,
            title: 'CBE',
            subtitle: 'Stadium, Addis Ababa',
            backgroundColor: const Color(0xFFF5F3FF), // Light purple
          ),
=======
            child: Text('Branches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          ),
<<<<<<< HEAD
          _buildBranchItem(context, Icons.business, 'GORO', 'GORO, Addis Ababa'),
          const SizedBox(height: 8),
          _buildBranchItem(context, Icons.business, 'CBE', 'Stadium, Addis Ababa'),
>>>>>>> 7d61e33541ea3ec1296aea576db4b7f8608ecfc8
          const SizedBox(height: 8),
=======
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
>>>>>>> 59d55fcba04bce7f95ca55415c0a89b7836e322e
        ],
      ),
    );
  }
<<<<<<< HEAD

<<<<<<< HEAD
  // Reusable branch item widget with different background colors
  Widget _buildBranchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
  }) {
    return Container(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Column 1: Building icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Column 2: Writings (title + subtitle)
=======
  Widget _buildBranchItem(BuildContext context, IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () => context.go('/branch-detail'),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 24),
          ),
          const SizedBox(width: 16),
>>>>>>> 7d61e33541ea3ec1296aea576db4b7f8608ecfc8
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          // Column 3: Arrow → (text arrow, not icon)
          const Text(
            '→',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
=======
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Text('→', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF))),
        ],
      ),
    ));
  }
=======
>>>>>>> 59d55fcba04bce7f95ca55415c0a89b7836e322e
}
>>>>>>> 7d61e33541ea3ec1296aea576db4b7f8608ecfc8
