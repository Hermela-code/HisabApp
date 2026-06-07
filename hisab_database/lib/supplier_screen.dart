import 'package:flutter/material.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  List<Map<String, String>> suppliers = [];

  void addSupplier() {
    setState(() {
      suppliers.add({
        "name": nameController.text,
        "phone": phoneController.text,
      });
    });

    nameController.clear();
    phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suppliers"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Supplier Name",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: addSupplier,
              child: const Text("Add Supplier"),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(suppliers[index]["name"]!),
                      subtitle: Text(suppliers[index]["phone"]!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}