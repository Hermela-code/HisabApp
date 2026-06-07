import 'package:flutter/material.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  List<Map<String, String>> customers = [];

  void addCustomer() {
    setState(() {
      customers.add({
        "name": nameController.text,
        "email": emailController.text,
      });
    });

    nameController.clear();
    emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customers"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Customer Name",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: addCustomer,
              child: const Text("Add Customer"),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(customers[index]["name"]!),
                      subtitle: Text(customers[index]["email"]!),
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