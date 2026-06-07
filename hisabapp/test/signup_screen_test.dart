import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/application/use_cases/auth/register_user_use_case.dart';
import 'package:hisabapp/domain/entities/user.dart';
import 'package:hisabapp/features/Auth/signup/signup.dart';
import 'cashier_provider_test.dart';

class MockRegisterUserUseCase extends RegisterUserUseCase {
  final Future<void> Function(User user) onExecute;
  MockRegisterUserUseCase(super.repository, this.onExecute);

  @override
  Future<void> execute(User user) {
    return onExecute(user);
  }
}

void main() {
  late FakeAppRepository fakeRepo;
  late RegisterUserUseCase originalUseCase;

  setUp(() {
    fakeRepo = FakeAppRepository();
    originalUseCase = registerUserUseCase;
  });

  tearDown(() {
    registerUserUseCase = originalUseCase;
  });

  Widget createSignupScreen(GoRouter router) {
    return ProviderScope(
      overrides: [
        appRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('shows validation error when fields are empty', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/signup',
      routes: [
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    );

    await tester.pumpWidget(createSignupScreen(router));
    await tester.pumpAndSettle();

    // Click signup button immediately
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please fill in all required fields.'), findsOneWidget);
  });

  testWidgets('shows validation error when role is not selected', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/signup',
      routes: [
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    );

    await tester.pumpWidget(createSignupScreen(router));
    await tester.pumpAndSettle();

    // Fill username and passwords
    await tester.enterText(find.byType(TextFormField).first, 'new_user');
    await tester.enterText(find.byType(TextFormField).at(1), 'pass123');
    await tester.enterText(find.byType(TextFormField).at(2), 'pass123');

    // Click signup button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please select your role.'), findsOneWidget);
  });

  testWidgets('shows validation error when passwords do not match', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/signup',
      routes: [
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    );

    await tester.pumpWidget(createSignupScreen(router));
    await tester.pumpAndSettle();

    // Fill credentials with mismatched password
    await tester.enterText(find.byType(TextFormField).first, 'new_user');
    await tester.enterText(find.byType(TextFormField).at(1), 'pass123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different_pass');

    // Select role
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Owner').last);
    await tester.pumpAndSettle();

    // Click signup
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  testWidgets('creates account and navigates to owner dashboard on successful owner signup', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/signup',
      routes: [
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/owner-dashboard',
          builder: (context, state) => const Scaffold(body: Text('Owner Dashboard Screen')),
        ),
      ],
    );

    // Mock usecase execution
    registerUserUseCase = MockRegisterUserUseCase(fakeRepo, (user) async {});

    await tester.pumpWidget(createSignupScreen(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'new_owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'pass123');
    await tester.enterText(find.byType(TextFormField).at(2), 'pass123');

    // Select role
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Owner').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Account created successfully.'), findsOneWidget);
    expect(find.text('Owner Dashboard Screen'), findsOneWidget);
  });
}
