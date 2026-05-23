import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/presentation/widgets/owner_header.dart';

class OwnerRecordSalePage extends StatefulWidget {
  const OwnerRecordSalePage({super.key});

  @override
  State<OwnerRecordSalePage> createState() => _OwnerRecordSalePageState();
}

class _OwnerRecordSalePageState extends State<OwnerRecordSalePage> {
  String? selectedElectronicsType;
  String? selectedProductName;
  String? selectedModel;
  String? selectedSpecification;
  String? selectedSalesperson;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final List<String> electronicsTypes = ['Smartphones', 'Laptops', 'Tablets', 'Accessories'];
  final List<String> productNames = ['iPhone 15', 'Samsung S24', 'MacBook Pro', 'iPad Air'];
  final List<String> models = ['128GB', '256GB', '512GB', '1TB'];
  final List<String> specifications = ['6.1 inch', '6.7 inch', '13 inch', '11 inch'];
  final List<String> salespersons = ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Williams'];

  void updateTotal() {
    int quantity = int.tryParse(quantityController.text) ?? 0;
    int unitPrice = int.tryParse(unitPriceController.text) ?? 0;
    totalController.text = (quantity * unitPrice).toString();
  }

  @override
  void initState() {
    super.initState();
    quantityController.addListener(updateTotal);
    unitPriceController.addListener(updateTotal);
  }

  @override
  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    totalController.dispose();
    customerNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OwnerLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Record Sale', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 6),
            Opacity(opacity: 0.5, child: const Text('Log New Transaction', style: TextStyle(fontSize: 16, color: Colors.black))),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown('Electronics Type', electronicsTypes, selectedElectronicsType, 'Select Product',
                      (v) => setState(() => selectedElectronicsType = v)),
                  const SizedBox(height: 20),
                  _buildDropdown('Product Name', productNames, selectedProductName, 'Select Product',
                      (v) => setState(() => selectedProductName = v)),
                  const SizedBox(height: 20),
                  _buildDropdown('Model', models, selectedModel, 'Select Model',
                      (v) => setState(() => selectedModel = v)),
                  const SizedBox(height: 20),
                  _buildDropdown('Specification', specifications, selectedSpecification, 'Select Product',
                      (v) => setState(() => selectedSpecification = v)),
                  const SizedBox(height: 24),

                  Row(children: [
                    Expanded(child: _buildTextField('Quantity', quantityController, hint: '1', isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Unit Price', unitPriceController, hint: '0', isNumber: true, prefix: '\$ ')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Total', totalController, hint: '\$0', readOnly: true)),
                  ]),
                  const SizedBox(height: 20),

                  _buildDropdown('Salesperson', salespersons, selectedSalesperson, 'Select Salesperson',
                      (v) => setState(() => selectedSalesperson = v)),
                  const SizedBox(height: 20),

                  Row(children: [
                    Expanded(child: _buildTextField('Customer Name', customerNameController, hint: 'Optional')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Phone Number', phoneNumberController, hint: 'Optional', isPhone: true)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (selectedElectronicsType == null || selectedProductName == null ||
                      selectedModel == null || selectedSpecification == null ||
                      selectedSalesperson == null || quantityController.text.isEmpty ||
                      unitPriceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
                    );
                  } else {
                    context.go('/branch-detail');
                  }
                },
                icon: const Icon(Icons.shopping_cart, size: 20, color: Colors.black),
                label: const Text('Record Sales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/branch-detail'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey.shade500, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, String hint, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Opacity(opacity: 0.5, child: Text(hint)),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String hint = '', bool isNumber = false, bool isPhone = false, bool readOnly = false, String prefix = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: isNumber ? TextInputType.number : isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixText: prefix.isEmpty ? null : prefix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}
