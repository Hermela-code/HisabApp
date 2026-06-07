import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController productController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  List<Map<String, dynamic>> products = [];

  void addProduct() {
    if (productController.text.isNotEmpty &&
        quantityController.text.isNotEmpty) {
      setState(() {
        products.add({
          "name": productController.text,
          "quantity": int.parse(quantityController.text),
        });
      });

      productController.clear();
      quantityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Management"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: productController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addProduct,
                child: const Text("Add Product"),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Current Stock",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory),
                      title: Text(products[index]["name"]),
                      subtitle: Text(
                        "Quantity: ${products[index]["quantity"]}",
                      ),
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