import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This constructor tells Flutter to use GoRouter for all navigation
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'HisabApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
    );
  }
}