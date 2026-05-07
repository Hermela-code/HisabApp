import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/widgets/owner_header.dart';

class BranchPage extends StatelessWidget {
  const BranchPage({super.key});

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
              child: Text('2 branches', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18, color: Colors.black),
              label: const Text('Add Branch', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),

            _buildBranchCard(context, 'GORO', 'GORO, Addis Ababa', 'Helen'),
            const SizedBox(height: 20),
            _buildBranchCard(context, 'CBE', 'Stadium, Addis Ababa', 'Helen'),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, String branchName, String locationText, String personCode) {
    return Container(
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
              Text(locationText, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ]),
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: 0.6,
            child: Row(children: [
              Icon(Icons.person, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(personCode, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ]),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_upload, size: 18, color: Colors.black),
              label: const Text('Export today', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(200, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
