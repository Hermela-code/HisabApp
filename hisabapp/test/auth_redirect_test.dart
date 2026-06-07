import 'package:flutter_test/flutter_test.dart';
import 'package:hisabapp/core/navigation/app_router.dart';
import 'package:hisabapp/core/navigation/auth_redirect.dart';
import 'package:hisabapp/domain/entities/user.dart';

void main() {
  const owner = User(
    id: 1,
    username: 'owner',
    password: 'pass',
    role: UserRole.owner,
    companyId: 1,
  );

  const cashier = User(
    id: 2,
    username: 'cashier',
    password: 'pass',
    role: UserRole.cashier,
    companyId: 1,
    branchId: 1,
  );

  group('resolveAuthRedirect', () {
    test('unauthenticated user on public route stays', () {
      expect(
        resolveAuthRedirect(user: null, matchedLocation: AppRouter.login),
        isNull,
      );
    });

    test('unauthenticated user on protected route goes to login', () {
      expect(
        resolveAuthRedirect(
          user: null,
          matchedLocation: AppRouter.cashierDashboard,
        ),
        AppRouter.login,
      );
    });

    test('logged-in cashier on owner route redirected to cashier dashboard', () {
      expect(
        resolveAuthRedirect(
          user: cashier,
          matchedLocation: AppRouter.ownerDashboard,
        ),
        AppRouter.cashierDashboard,
      );
    });

    test('logged-in owner on cashier route redirected to owner dashboard', () {
      expect(
        resolveAuthRedirect(
          user: owner,
          matchedLocation: AppRouter.cashierDashboard,
        ),
        AppRouter.ownerDashboard,
      );
    });

    test('logged-in cashier on cashier route allowed', () {
      expect(
        resolveAuthRedirect(
          user: cashier,
          matchedLocation: AppRouter.cashierInventory,
        ),
        isNull,
      );
    });

    test('logged-in owner on owner route allowed', () {
      expect(
        resolveAuthRedirect(
          user: owner,
          matchedLocation: AppRouter.branchDetail,
        ),
        isNull,
      );
    });

    test('logged-in user on login redirected to role home', () {
      expect(
        resolveAuthRedirect(user: cashier, matchedLocation: AppRouter.login),
        AppRouter.cashierDashboard,
      );
      expect(
        resolveAuthRedirect(user: owner, matchedLocation: AppRouter.login),
        AppRouter.ownerDashboard,
      );
    });
  });

  group('route classification helpers', () {
    test('isCashierRoute matches cashier prefix', () {
      expect(isCashierRoute(AppRouter.cashierRecordSale), isTrue);
      expect(isCashierRoute(AppRouter.ownerDashboard), isFalse);
    });

    test('isOwnerRoute matches owner paths only', () {
      expect(isOwnerRoute(AppRouter.ownerBranches), isTrue);
      expect(isOwnerRoute(AppRouter.cashierDashboard), isFalse);
    });
  });
}
