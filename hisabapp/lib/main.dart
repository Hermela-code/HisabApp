import 'package:flutter/material.dart';
// Updated import path: point directly to the file containing DeleteProductView
import 'package:hisabapp/features/Auth/registration/attribute.dart';

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
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const Scaffold(
        backgroundColor: Colors.white12,
        body: Center(
          // Removed the invalid 'const' keyword
          child: ProductAttributesScreen(), 
        ),
      ),
    );
  }
}