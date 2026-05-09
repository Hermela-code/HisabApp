import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

// --- 1. THE SHARED HEADER ---
class HisabHeader extends StatelessWidget implements PreferredSizeWidget {
  const HisabHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.15),
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textMain, size: 30),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Image.asset('assets/images/logo1.jpg', height: 40, fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_cart, color: Colors.orange)),
          const SizedBox(width: 8),
          const Text('HisabApp', style: TextStyle(color: AppColors.textMain, fontSize: 24, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// --- 2. THE CASHIER SIDEBAR ---
class CashierSidebar extends StatelessWidget {
  const CashierSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color sidebarBg = Color(0xFF0F172A);

    return Drawer(
      backgroundColor: sidebarBg,
      child: Column(
        children: [
          // MINIMIZED HEADER SECTION
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, bottom: 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white12, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Icon(Icons.storefront, color: Colors.orange, size: 28),
                const SizedBox(width: 10), // Tightened spacing
                Text(
                  'HisabApp',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // NAVIGATION ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, Icons.grid_view, "Dashboard", '/cashier-dashboard'),
                _buildMenuItem(context, Icons.inventory_2_outlined, "Inventory", '/cashier-inventory'),
                _buildMenuItem(context, Icons.shopping_cart_outlined, "Record Sale", '/cashier-record-sale'),
                _buildMenuItem(context, Icons.attach_money, "Daily Sales", '/cashier-daily-sales'),
                _buildMenuItem(context, Icons.monetization_on_outlined, "Branch Costs", '/cashier-branch-cost'),
                _buildMenuItem(context, Icons.ios_share_outlined, "Export / Archive", '/cashier-export-archive'),
                _buildMenuItem(context, Icons.people_outline, "Staff", '/cashier-staff'),
                _buildMenuItem(context, Icons.logout, "Logout", '/select-role'),
              ],
            ),
          ),

          // SETTINGS AT BOTTOM
          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
          _buildMenuItem(context, Icons.settings_outlined, "Settings", '/settings'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String? route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
      onTap: route == null ? null : () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}

// --- 3. THE MERGED LAYOUT WIDGET ---
class CashierLayout extends StatelessWidget {
  final Widget body;
  const CashierLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HisabHeader(),
      drawer: const CashierSidebar(),
      backgroundColor: Colors.white,
      body: body,
    );
  }
}

// --- TESTING BLOCK ---
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CashierLayout(
        body: Center(
          child: Text(
            "Cashier Layout Ready\nClick the menu to see the sidebar",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}