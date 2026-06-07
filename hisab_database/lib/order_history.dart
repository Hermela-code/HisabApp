import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {"product": "Laptop", "qty": "2"},
      {"product": "Mouse", "qty": "5"},
      {"product": "Keyboard", "qty": "3"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(orders[index]["product"]!),
              subtitle: Text(
                "Quantity: ${orders[index]["qty"]}",
              ),
            ),
          );
        },
      ),
    );
  }
}