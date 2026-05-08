import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BusinessTypeScreen extends StatefulWidget {
  final String role;
  const BusinessTypeScreen({super.key, required this.role});

  @override
  State<BusinessTypeScreen> createState() => _BusinessTypeScreenState();
}

class _BusinessTypeScreenState extends State<BusinessTypeScreen> {
  String? selectedCategory;

  final List<String> categories = [
    'Electronics Store',
    'Grocery / Supermarket',
    'Pharmacy',
    'Clothing & Boutique',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            children: [
              Image.asset('assets/images/logo1.jpg', height: 100, fit: BoxFit.contain),
              const SizedBox(height: 20),
              const Text('Welcome to HisabApp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Set up your business in a few steps', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('What type of business do you run?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      hint: const Text('Select your business category', style: TextStyle(fontSize: 14)),
                      value: selectedCategory,
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (value) => setState(() => selectedCategory = value),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: selectedCategory == null
                            ? null
                            : () => context.go('/attribute', extra: widget.role),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    onPressed: () => context.go('/select-role'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Back', style: TextStyle(color: Colors.black87)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
