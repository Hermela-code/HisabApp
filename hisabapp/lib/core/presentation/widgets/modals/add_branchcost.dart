import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/core/presentation/theme/app_colors.dart';

class AddBranchCostModal extends StatefulWidget {
  final void Function(String description, int amount) onAddCost;
  const AddBranchCostModal({super.key, required this.onAddCost});

  @override
  State<AddBranchCostModal> createState() => _AddBranchCostModalState();
}

class _AddBranchCostModalState extends State<AddBranchCostModal> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3, offset: const Offset(0, 2)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  const Text('Add Branch Cost', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildLabel('Description'),
              _buildTextField(_descriptionController, 'e.g Tea, Transport'),
              const SizedBox(height: 12),

              _buildLabel('Amount'),
              _buildTextField(_amountController, '0', isNumber: true),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAddCost(
                      _descriptionController.text.trim(),
                      int.tryParse(_amountController.text) ?? 0,
                    );
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Add Cost', style: TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textGray),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMain, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMain)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.textGray)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.textGray)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primaryYellow)),
        ),
      ),
    );
  }
}
