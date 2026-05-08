import 'package:flutter/material.dart';
import 'package:hisabapp/features/cashier/cashier_dashboard.dart';

void main() {
  runApp(const HisabApp());
}

class HisabApp extends StatelessWidget {
  const HisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HisabApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const CashierDashboard(),
    );
  }
}
