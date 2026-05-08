import 'package:flutter/material.dart';

class BusinessTypeScreen extends StatefulWidget {
  const BusinessTypeScreen({super.key});

  @override
  State<BusinessTypeScreen> createState() => _BusinessTypeScreenState();
}

class _BusinessTypeScreenState extends State<BusinessTypeScreen> {
  // To hold the selected value from the dropdown
  String? selectedCategory;

  // Example list of categories - you can change these later
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your business in a few steps',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // 3. Selection Card
              Container(
                padding: const EdgeInsets.all(24.0),
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
                      'What type of business do you run?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      hint: const Text('Select your business category', style: TextStyle(fontSize: 14)),
                      value: selectedCategory,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: selectedCategory == null 
                          ? null // Disable button if nothing is selected
                          : () {
                              // TODO: Handle navigation
                              print("Selected: $selectedCategory");
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Match the orange in your image
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder( // Removed the extra "Rectangle"
                          borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 4. Back Button (Aligned to the right like your image)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.black87),
                    ),
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