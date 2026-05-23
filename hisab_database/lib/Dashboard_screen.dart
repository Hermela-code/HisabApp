import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRecentActivity({
    required String product,
    required String action,
    required String time,
  }) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.inventory),
      ),

      title: Text(product),

      subtitle: Text(action),

      trailing: Text(
        time,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            buildDashboardCard(
              icon: Icons.inventory_2,
              title: "Total Products",
              value: "248",
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            buildDashboardCard(
              icon: Icons.warning_amber,
              title: "Low Stock Items",
              value: "12",
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            buildDashboardCard(
              icon: Icons.attach_money,
              title: "Total Sales",
              value: "\$18,400",
              color: Colors.green,
            ),

            const SizedBox(height: 30),

            const Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: [

                  buildRecentActivity(
                    product: "Laptop",
                    action: "Stock Updated",
                    time: "2m ago",
                  ),

                  buildRecentActivity(
                    product: "Keyboard",
                    action: "New Product Added",
                    time: "10m ago",
                  ),

                  buildRecentActivity(
                    product: "Mouse",
                    action: "Low Stock Alert",
                    time: "25m ago",
                  ),buildRecentActivity(
                    product: "Monitor",
                    action: "Order Completed",
                    time: "1h ago",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}