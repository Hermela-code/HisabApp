import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/widgets/cashier_header.dart';
import 'package:hisabapp/core/presentation/widgets/modals/add_staff.dart';
import 'package:hisabapp/core/presentation/widgets/modals/delete.dart';

class StaffPerformance extends StatelessWidget {
  const StaffPerformance({super.key});

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
    return CashierLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Staff Performance', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Track sales by salesperson', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),

            SizedBox(
              width: 170,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => _showBlurModal(context, const AddStaffView()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A007),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 32),

            const Text('search staff', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, size: 20, color: Colors.black54),
                  hintText: 'Select Category',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildStaffCard(context, name: 'Samuel Girma', phone: '+251987654321', totalUnits: '10 units', breakdown: ['.camon 20 - 4', '.iphone 12 - 6']),
            const SizedBox(height: 16),
            _buildStaffCard(context, name: 'Hana Belew', phone: '+251987654321', totalUnits: '5 units', breakdown: ['.camon 20 - 1', '.iphone 12 - 4']),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, {
    required String name,
    required String phone,
    required String totalUnits,
    required List<String> breakdown,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(phone, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(totalUnits, style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
          ...breakdown.map((item) => Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          )),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () => _showBlurModal(context, const DeleteProductView()),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
