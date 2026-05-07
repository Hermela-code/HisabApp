import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Logo
              Image.asset(
                'assets/images/logo1.jpg', // <-- Make sure your asset path is correct
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              // 2. Welcome & Role Text
              const Text(
                'Welcome to HisabApp',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "You're logged in. How will you use the app today?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4, // Improves readability for multi-line text
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                'Select your role.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // 3. Action Cards
              // These cards react when tapped. We'll add the navigation soon.
              RoleCard(
                icon: Icons.storefront_outlined,
                title: 'Owner',
                description:
                    'View all branches, manage operational costs, and profitability.',
                onTap: () {
                  // TODO: Navigate to Owner Dashboard
                  print('Navigate to Owner Dashboard');
                },
              ),
              const SizedBox(height: 20),
              RoleCard(
                icon: Icons.shopping_cart_outlined,
                title: 'Cashier',
                description:
                    'Record daily sales, manage inventory, branch cost, and export daily report.',
                onTap: () {
                  // TODO: Navigate to Cashier Dashboard
                  print('Navigate to Cashier Dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom widget that builds the interactive role cards (Owner/Cashier)
class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Soft shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // InkWell adds the tap effect without needing a complicated button widget
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Icon on the Left
              Icon(
                icon,
                size: 50,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 20),
              // Text Content (Expanded so it can use multiple lines smoothly)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 3, // Prevents overly long text from breaking layout
                      overflow: TextOverflow.ellipsis,
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