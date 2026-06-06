import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabapp/main.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/domain/entities/user.dart';
import 'package:hisabapp/domain/entities/product.dart';
import 'package:hisabapp/domain/entities/staff.dart';
import 'package:hisabapp/features/Auth/registration/select_role.dart';
import '../test/cashier_provider_test.dart';

void main() {
  group('E2E Onboarding & Cashier CRUD Integration Test', () {
    late FakeAppRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAppRepository();

      // Override the global use cases and repository singletons with our mock/fake
      appRepository = fakeRepo;
      loginUserUseCase = LoginUserUseCase(fakeRepo);
      registerUserUseCase = RegisterUserUseCase(fakeRepo);
      recordSaleUseCase = RecordSaleUseCase(fakeRepo);

      // Pre-populate product and staff to allow recording a sale
      fakeRepo.products.add(Product(
        id: 1,
        name: 'iPhone 15',
        model: 'Pro Max',
        specification: '256GB',
        category: ProductCategories.mobile,
        stock: 10,
        unitPrice: 1200,
        branchId: 1,
      ));

      fakeRepo.staff.add(Staff(
        id: 1,
        name: 'John Cashier',
        phone: '555-0199',
        branchId: 1,
      ));
    });

    testWidgets('completes onboarding, registers cashier, and records a sale', (tester) async {
      // 1. Launch the app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Landing / Welcome Screen
      expect(find.text('Welcome to HisabApp'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // 2. Click "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify Role Selection Screen
      expect(find.text('Select your role.'), findsOneWidget);
      final cashierRoleCard = find.widgetWithText(RoleCard, 'Cashier');
      expect(cashierRoleCard, findsOneWidget);

      // Select Cashier and Continue
      await tester.tap(cashierRoleCard);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue as Cashier'));
      await tester.pumpAndSettle();

      // 3. Business Type Selection Screen
      expect(find.text('What type of business do you run?'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Electronics Store').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // 4. Product Attributes Screen
      expect(find.text('Define your product attributes.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Model');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish setup'));
      await tester.pumpAndSettle();

      // 5. Signup Screen
      expect(find.text('Create Account'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, 'john_cashier');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      
      // Wait for navigation to settle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // 6. Cashier Dashboard
      expect(find.text('Cashier Dashboard'), findsOneWidget);
      expect(find.text('Record sale'), findsOneWidget);

      // Verify metrics show 10 units in stock
      expect(find.text('10'), findsOneWidget);

      // 7. Click "Record sale"
      await tester.tap(find.text('Record sale'));
      await tester.pumpAndSettle();

      // Verify Record Sale Page
      expect(find.text('Record Sale'), findsOneWidget);

      // Fill sale details dropdowns
      // Electronics Type
      await tester.tap(find.text('Select type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ProductCategories.mobile).last);
      await tester.pumpAndSettle();

      // Product Name
      await tester.tap(find.text('Select product'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('iPhone 15').last);
      await tester.pumpAndSettle();

      // Model
      await tester.tap(find.text('Select Model'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pro Max').last);
      await tester.pumpAndSettle();

      // Specification
      await tester.tap(find.text('Select Specification'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('256GB').last);
      await tester.pumpAndSettle();

      // Quantity (enter 2 units)
      await tester.enterText(find.widgetWithText(TextField, '1'), '2');
      await tester.pumpAndSettle();

      // Salesperson
      await tester.tap(find.text('Select Salesperson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('John Cashier').last);
      await tester.pumpAndSettle();

      // 8. Submit Sale
      await tester.tap(find.text('Record Sales'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Navigated to Daily Sales Screen
      expect(find.text('Daily Sales'), findsOneWidget);
    });
  });
}
