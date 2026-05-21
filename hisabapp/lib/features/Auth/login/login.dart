import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../application/di.dart';
import '../../../domain/entities/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    final username = _userNameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password.')),
      );
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role before login.')),
      );
      return;
    }

    final user = await loginUserUseCase.execute(username, password);
    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password.')),
      );
      return;
    }

    if (user.role == UserRole.cashier) {
      context.go('/cashier-dashboard');
    } else {
      context.go('/owner-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo1.jpg', height: 100, fit: BoxFit.contain),
              const SizedBox(height: 12),
              const Text('Log in', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 6),
              const Text(
                'Enter your detail to get started with HisabApp',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              _buildInputField(label: 'User Name', controller: _userNameController),
              const SizedBox(height: 14),
              _buildInputField(label: 'Password', controller: _passwordController, isPassword: true),
              const SizedBox(height: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    hint: const Text('Select your role', style: TextStyle(fontSize: 13)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.orange, width: 2)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cashier', child: Text('Cashier', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'owner', child: Text('Owner', style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: (value) => setState(() => _selectedRole = value),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF39C12),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: const Text('Sign up', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.orange, width: 2)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
