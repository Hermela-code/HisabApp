import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/core/presentation/theme/app_colors.dart';

typedef ProductUpdateCallback = void Function(
  String name,
  String model,
  String specification,
  int sellingPrice,
  int costPrice,
  int stock,
);

class UpdateProductView extends StatefulWidget {
  final String? initialName;
  final String? initialModel;
  final String? initialSpecification;
  final int? initialSellingPrice;
  final int? initialCostPrice;
  final int? initialStock;
  final ProductUpdateCallback? onUpdate;
  final bool showCostFields;

  const UpdateProductView({
    super.key,
    this.initialName,
    this.initialModel,
    this.initialSpecification,
    this.initialSellingPrice,
    this.initialCostPrice,
    this.initialStock,
    this.onUpdate,
    this.showCostFields = true,
  });

  @override
  State<UpdateProductView> createState() => _UpdateProductViewState();
}

class _UpdateProductViewState extends State<UpdateProductView> {
  late final TextEditingController _nameController;
  late final TextEditingController _modelController;
  late final TextEditingController _specController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _modelController = TextEditingController(text: widget.initialModel ?? '');
    _specController = TextEditingController(text: widget.initialSpecification ?? '');
    _sellingPriceController = TextEditingController(
      text: widget.initialSellingPrice != null && widget.initialSellingPrice! > 0
          ? widget.initialSellingPrice.toString()
          : '',
    );
    _costPriceController = TextEditingController(
      text: widget.initialCostPrice != null && widget.initialCostPrice! > 0
          ? widget.initialCostPrice.toString()
          : '',
    );
    _stockController = TextEditingController(
      text: widget.initialStock != null ? widget.initialStock.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _specController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2)),
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
                  const SizedBox(width: 24),
                  const Text('Update Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
                ],
              ),
              const SizedBox(height: 15),

              _buildLabel('Product Name'),
              _buildTextField(_nameController),
              const SizedBox(height: 10),

              _buildLabel('Model'),
              _buildTextField(_modelController),
              const SizedBox(height: 10),

              _buildLabel('Specification'),
              _buildTextField(_specController),
              const SizedBox(height: 15),

              if (widget.showCostFields)
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildLabel('Selling Price'),
                    _buildTextField(_sellingPriceController, keyboardType: TextInputType.number),
                  ])),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildLabel('Cost Price'),
                    _buildTextField(_costPriceController, keyboardType: TextInputType.number),
                  ])),
                ])
              else ...[
                _buildLabel('Selling Price'),
                _buildTextField(_sellingPriceController, keyboardType: TextInputType.number),
              ],
              const SizedBox(height: 15),

              _buildLabel('Stock (units)'),
              _buildTextField(_stockController, keyboardType: TextInputType.number),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) return;
                    widget.onUpdate?.call(
                      name,
                      _modelController.text.trim(),
                      _specController.text.trim(),
                      int.tryParse(_sellingPriceController.text) ?? 0,
                      widget.showCostFields ? int.tryParse(_costPriceController.text) ?? 0 : 0,
                      int.tryParse(_stockController.text) ?? 0,
                    );
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Update', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textGray),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMain)),
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
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain)),
    );
  }

  Widget _buildTextField(TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.textGray)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.textGray)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primaryYellow)),
        ),
      ),
    );
  }
}
