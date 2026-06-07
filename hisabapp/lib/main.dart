import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router_provider.dart';
import 'core/platform/path_provider_registrar.dart';
import 'core/platform/sqlite_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSqlite();
  registerDesktopPathProvider();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
=======
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
>>>>>>> 59d55fcba04bce7f95ca55415c0a89b7836e322e
    return MaterialApp.router(
      routerConfig: router,
      title: 'HisabApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
    );
  }
}