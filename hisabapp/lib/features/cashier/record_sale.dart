import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Branch Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RecordSalePage(),
      routes: {
        '/record-sale': (context) => const RecordSalePage(),
      },
    );
  }
}

class RecordSalePage extends StatefulWidget {
  const RecordSalePage({super.key});

  @override
  State<RecordSalePage> createState() => _RecordSalePageState();
}

class _RecordSalePageState extends State<RecordSalePage> {
  // Dropdown selections
  String? selectedElectronicsType;
  String? selectedProductName;
  String? selectedModel;
  String? selectedSpecification;
  String? selectedSalesperson;

  // Text field controllers
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  // Sample data for dropdowns
  final List<String> electronicsTypes = ['Smartphones', 'Laptops', 'Tablets', 'Accessories'];
  final List<String> productNames = ['iPhone 15', 'Samsung S24', 'MacBook Pro', 'iPad Air'];
  final List<String> models = ['128GB', '256GB', '512GB', '1TB'];
  final List<String> specifications = ['6.1 inch', '6.7 inch', '13 inch', '11 inch'];
  final List<String> salespersons = ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Williams'];

  // Auto-calculate total when quantity or unit price changes
  void updateTotal() {
    int quantity = int.tryParse(quantityController.text) ?? 0;
    int unitPrice = int.tryParse(unitPriceController.text) ?? 0;
    int total = quantity * unitPrice;
    totalController.text = total.toString();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Record Sale'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading: Record Sale
            const Text(
              'Record Sale',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle: Log New Transaction (low opacity)
            Opacity(
              opacity: 0.5,
              child: const Text(
                'Log New Transaction',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main input box
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
                  // 1. Electronics Type dropdown
                  const Text(
                    'Electronics Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedElectronicsType,
                        hint: Opacity(
                          opacity: 0.5,
                          child: const Text('Select Product'),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: electronicsTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedElectronicsType = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Product Name dropdown
                  const Text(
                    'Product Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedProductName,
                        hint: Opacity(
                          opacity: 0.5,
                          child: const Text('Select Product'),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: productNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProductName = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Model dropdown
                  const Text(
                    'Model',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedModel,
                        hint: Opacity(
                          opacity: 0.5,
                          child: const Text('Select Model'),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: models.map((model) {
                          return DropdownMenuItem(
                            value: model,
                            child: Text(model),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedModel = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Specification dropdown
                  const Text(
                    'Specification',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSpecification,
                        hint: Opacity(
                          opacity: 0.5,
                          child: const Text('Select Product'),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: specifications.map((spec) {
                          return DropdownMenuItem(
                            value: spec,
                            child: Text(spec),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSpecification = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3-column row: Quantity, Unit Price, Total
                  Row(
                    children: [
                      // Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '1',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Unit Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Unit Price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: unitPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                prefixText: '\$ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Total
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: totalController,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: '\$0',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Salesperson dropdown
                  const Text(
                    'Salesperson',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSalesperson,
                        hint: Opacity(
                          opacity: 0.5,
                          child: const Text('Select Salesperson'),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: salespersons.map((person) {
                          return DropdownMenuItem(
                            value: person,
                            child: Text(person),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSalesperson = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2-column row: Customer Name & Phone Number
                  Row(
                    children: [
                      // Customer Name (optional)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer Name',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: customerNameController,
                              decoration: InputDecoration(
                                hintText: 'Optional',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone Number (optional)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Optional',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Two buttons in column
            // Button 1: Record Sales (golden background with shopping cart icon)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show validation message
                  if (selectedElectronicsType == null ||
                      selectedProductName == null ||
                      selectedModel == null ||
                      selectedSpecification == null ||
                      selectedSalesperson == null ||
                      quantityController.text.isEmpty ||
                      unitPriceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Recorded Sale: ${selectedProductName} - \$${totalController.text}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.shopping_cart, size: 20, color: Colors.black),
                label: const Text(
                  'Record Sales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Button 2: Close (white background, black/grey outline)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade500, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}