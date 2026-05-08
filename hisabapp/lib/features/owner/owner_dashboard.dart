import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

            _buildBranchesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox1() {
    return _metricBox(
      label: 'BRANCHES',
      value: '2',
      icon: Icons.business,
      iconBg: const Color(0xFFE6F0FF),
      iconColor: const Color(0xFF3B82F6),
    );
  }

  Widget _buildMetricBox2() {
    return _metricBox(
      label: 'Total income',
      value: '\$240,000',
      icon: Icons.trending_up,
      iconBg: Color(0x1A4CAF50),
      iconColor: Colors.green,
    );
  }

  Widget _buildMetricBox3() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('OP. Costes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
          SizedBox(height: 8),
          Text('\$0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  Widget _buildMetricBox4() {
    return _metricBox(
      label: 'NET/EST.',
      value: '\$139,600',
      icon: Icons.trending_up,
      iconBg: Color(0x1A2196F3),
      iconColor: Colors.blue,
    );
  }

  Widget _metricBox({required String label, required String value, required IconData icon, required Color iconBg, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 32),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
    );
  }

  Widget _buildBranchesSection() {
    return Container(
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
          _buildBranchItem(Icons.business, 'GORO', 'GORO, Addis Ababa'),
          const SizedBox(height: 8),
          _buildBranchItem(Icons.business, 'CBE', 'Stadium, Addis Ababa'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBranchItem(IconData icon, String title, String subtitle) {
    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Text('→', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
