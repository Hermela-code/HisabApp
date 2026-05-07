import 'package:flutter/material.dart';

class ProductAttributesScreen extends StatefulWidget {
  const ProductAttributesScreen({super.key});

  @override
  State<ProductAttributesScreen> createState() => _ProductAttributesScreenState();
}

class _ProductAttributesScreenState extends State<ProductAttributesScreen> {
  final TextEditingController _attributeController = TextEditingController();
  final List<String> _attributes = [];

  void _addAttribute() {
    if (_attributeController.text.isNotEmpty) {
      setState(() {
        _attributes.add(_attributeController.text);
        _attributeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            children: [
              // 1. Logo
              Image.asset(
                'assets/images/logo1.jpg',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // 2. Titles
              const Text(
                'Welcome to HisabApp',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your business in a few steps',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // 3. Attribute Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Define your product attributes.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // Input Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: TextField(
                              controller: _attributeController,
                              decoration: InputDecoration(
                                hintText: 'e.g. Model',
                                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _addAttribute,
                            icon: const Icon(Icons.add, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Attributes List / Empty State
                    if (_attributes.isEmpty)
                      const Text(
                        'No attribute added yet',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        children: _attributes.map((attr) => Chip(
                          label: Text(attr, style: const TextStyle(fontSize: 12)),
                          onDeleted: () => setState(() => _attributes.remove(attr)),
                        )).toList(),
                      ),

                    const SizedBox(height: 25),

                    // Action Buttons (Back and Finish)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: const Text('Back', style: TextStyle(color: Colors.black87)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Logic to finish setup and save to DB
                              print("Setup Finished with: $_attributes");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3D6A6), // Pale gold/orange from image
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Finish setup', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}