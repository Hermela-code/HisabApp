import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/application/use_cases/auth/login_user_use_case.dart';
import 'package:hisabapp/domain/entities/user.dart';
import 'package:hisabapp/features/Auth/login/login.dart';
import 'cashier_provider_test.dart';

class MockLoginUserUseCase extends LoginUserUseCase {
  final Future<User?> Function(String username, String password) onExecute;
  MockLoginUserUseCase(super.repository, this.onExecute);

  @override
  Future<User?> execute(String username, String password) {
    return onExecute(username, password);
  }
}

void main() {
  late FakeAppRepository fakeRepo;
  late LoginUserUseCase originalUseCase;

  setUp(() {
    fakeRepo = FakeAppRepository();
    originalUseCase = loginUserUseCase;
  });

  tearDown(() {
    loginUserUseCase = originalUseCase;
  });

  Widget createLoginScreen(GoRouter router) {
    return ProviderScope(
      overrides: [
        appRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('shows validation snackbar if fields are empty', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

    await tester.pumpWidget(createLoginScreen(router));
    await tester.pumpAndSettle();

    // Click login button immediately
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start snackbar animation

    expect(find.text('Please enter both username and password.'), findsOneWidget);
  });

  testWidgets('shows validation snackbar if role is not selected', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

    await tester.pumpWidget(createLoginScreen(router));
    await tester.pumpAndSettle();

    // Fill credentials
    await tester.enterText(find.byType(TextFormField).first, 'test_user');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Click login without selecting role
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please select your role before login.'), findsOneWidget);
  });

  testWidgets('shows error snackbar on invalid credentials', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

    // Mock usecase to return null
    loginUserUseCase = MockLoginUserUseCase(fakeRepo, (user, pass) async => null);

    await tester.pumpWidget(createLoginScreen(router));
    await tester.pumpAndSettle();

    // Fill credentials
    await tester.enterText(find.byType(TextFormField).first, 'wrong_user');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong_pass');

    // Select Cashier role
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cashier').last);
    await tester.pumpAndSettle();

    // Tap login
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Invalid username or password.'), findsOneWidget);
  });

  testWidgets('shows error snackbar when role mismatch occurs', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

    // Mock usecase to return an OWNER user
    loginUserUseCase = MockLoginUserUseCase(
      fakeRepo,
      (user, pass) async => const User(
        id: 1,
        username: 'owner_user',
        password: 'password',
        role: UserRole.owner,
        companyId: 1,
      ),
    );

    await tester.pumpWidget(createLoginScreen(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'owner_user');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');

    // Select Cashier role instead of Owner
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cashier').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('This account is registered as Owner, not Cashier.'), findsOneWidget);
  });

  testWidgets('navigates to dashboard on successful login', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/cashier-dashboard',
          builder: (context, state) => const Scaffold(body: Text('Cashier Dashboard Screen')),
        ),
      ],
    );

    // Mock usecase to return a CASHIER user
    loginUserUseCase = MockLoginUserUseCase(
      fakeRepo,
      (user, pass) async => const User(
        id: 42,
        username: 'cashier_user',
        password: 'password',
        role: UserRole.cashier,
        companyId: 1,
        branchId: 1,
      ),
    );

    await tester.pumpWidget(createLoginScreen(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'cashier_user');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');

    // Select Cashier role
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cashier').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    
    // Wait for the async login execution and navigation to settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Cashier Dashboard Screen'), findsOneWidget);
  });
}
