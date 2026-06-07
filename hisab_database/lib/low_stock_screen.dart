import 'package:flutter/material.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lowStockProducts = [
      {"name": "Printer", "stock": "2"},
      {"name": "Monitor", "stock": "1"},
      {"name": "Scanner", "stock": "3"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Low Stock Alerts"),
      ),
      body: ListView.builder(
        itemCount: lowStockProducts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.warning,
                color: Colors.red,
              ),
              title: Text(
                lowStockProducts[index]["name"]!,
              ),
              subtitle: Text(
                "Remaining Stock: ${lowStockProducts[index]["stock"]}",
              ),
            ),
          );
        },
      ),
    );
  }
}