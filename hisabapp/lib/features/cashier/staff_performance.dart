import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabapp/application/providers/cashier_data_provider.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_staff.dart';
import 'package:hisabapp/core/presentation/widgets/modals/delete.dart';

class StaffPerformance extends ConsumerStatefulWidget {
  const StaffPerformance({super.key});

  @override
  ConsumerState<StaffPerformance> createState() => _StaffPerformanceState();
}

class _StaffPerformanceState extends ConsumerState<StaffPerformance> {
  String _searchQuery = '';

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

  void _showAddStaffModal() {
    _showBlurModal(
      AddStaffView(
        onAddStaff: (name, phoneNumber) {
          ref.read(cashierDataProvider.notifier).addStaff(
                name: name,
                phone: phoneNumber,
              );
        },
      ),
    );
  }

  void _showDeleteModal(CashierStaffMember member) {
    _showBlurModal(
      DeleteProductView(
        productName: member.name,
        onDelete: () {
          ref.read(cashierDataProvider.notifier).removeStaff(member.id);
        },
      ),
    );
  }

  List<StaffPerformanceInfo> _filteredStaff(List<StaffPerformanceInfo> list) {
    if (_searchQuery.isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list
        .where(
          (info) =>
              info.member.name.toLowerCase().contains(query) ||
              info.member.phone.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final performance = ref.watch(cashierDataProvider).staffPerformanceList();
    final filtered = _filteredStaff(performance);
    final countLabel =
        performance.length == 1 ? '1 staff member' : '${performance.length} staff members';

    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Staff Performance',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Track sales by salesperson',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(countLabel, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            SizedBox(
              width: 170,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: _showAddStaffModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add Staff',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Search staff', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, size: 20, color: Colors.black54),
                  hintText: 'Search by name or phone...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
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
                    performance.isEmpty
                        ? 'No staff yet. Tap Add Staff to register a salesperson.'
                        : 'No staff match your search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              )
            else
              ...filtered.asMap().entries.expand((entry) {
                final index = entry.key;
                final info = entry.value;
                return [
                  if (index > 0) const SizedBox(height: 16),
                  _buildStaffCard(info),
                ];
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffPerformanceInfo info) {
    final unitsLabel =
        info.totalUnits == 1 ? '1 unit' : '${info.totalUnits} units';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.member.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (info.member.phone.isNotEmpty)
                      Text(
                        info.member.phone,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showDeleteModal(info.member),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            unitsLabel,
            style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          if (info.breakdown.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'No sales recorded yet',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            )
          else
            ...info.breakdown.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              ),
            ),
        ],
      ),
    );
  }
}
