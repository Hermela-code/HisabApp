import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

// --- 1. THE OWNER HEADER ---
class OwnerHeader extends StatelessWidget implements PreferredSizeWidget {
  const OwnerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: AppColors.textMain,
          size: 30,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo1.jpg',
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.shopping_cart, color: Colors.orange);
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'HisabApp',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// --- 2. THE OWNER SIDEBAR ---
class OwnerSidebar extends StatelessWidget {
  const OwnerSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color sidebarBg = Color(0xFF0F172A);

    return Drawer(
      backgroundColor: sidebarBg,
      child: Column(
        children: [
          // MINIMIZED HEADER
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, bottom: 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white12, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
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

          // OWNER SPECIFIC NAVIGATION
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, Icons.grid_view, "Dashboard", '/owner-dashboard'),
                _buildMenuItem(context, Icons.business_outlined, "Branches", '/owner-branches'),
                _buildMenuItem(context, Icons.ios_share_outlined, "Exports", '/owner-exports'),
                _buildMenuItem(context, Icons.logout, "Logout", '/select-role'),
              ],
            ),
          ),

          // SETTINGS AT BOTTOM
          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
          _buildMenuItem(context, Icons.settings_outlined, "Settings", null),
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

// --- 3. THE OWNER LAYOUT WIDGET ---
class OwnerLayout extends StatelessWidget {
  final Widget body;
  const OwnerLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OwnerHeader(),
      drawer: const OwnerSidebar(),
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
      home: OwnerLayout(
        body: Center(
          child: Text(
            "Owner Dashboard View\nSidebar menu items updated.",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}