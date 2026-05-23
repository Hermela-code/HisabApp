import 'package:flutter_test/flutter_test.dart';
import 'package:hisabapp/core/navigation/app_router.dart';
import 'package:hisabapp/core/navigation/auth_redirect.dart';
import 'package:hisabapp/domain/entities/user.dart';

/// Ensures owner and cashier roles cannot access each other's primary flows.
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

  final ownerOnlyRoutes = [
    AppRouter.ownerDashboard,
    AppRouter.ownerBranches,
    AppRouter.branchDetail,
    AppRouter.ownerExports,
    AppRouter.ownerRecordSale,
  ];

  final cashierOnlyRoutes = [
    AppRouter.cashierDashboard,
    AppRouter.cashierInventory,
    AppRouter.cashierRecordSale,
    AppRouter.cashierDailySales,
    AppRouter.cashierBranchCost,
    AppRouter.cashierStaff,
    AppRouter.cashierExportArchive,
  ];

  test('cashier cannot access owner routes', () {
    for (final route in ownerOnlyRoutes) {
      expect(
        resolveAuthRedirect(user: cashier, matchedLocation: route),
        AppRouter.cashierDashboard,
        reason: 'cashier should be blocked from $route',
      );
    }
  });

  test('owner cannot access cashier routes', () {
    for (final route in cashierOnlyRoutes) {
      expect(
        resolveAuthRedirect(user: owner, matchedLocation: route),
        AppRouter.ownerDashboard,
        reason: 'owner should be blocked from $route',
      );
    }
  });

  test('homeForRole returns correct dashboard per role', () {
    expect(homeForRole(UserRole.cashier), AppRouter.cashierDashboard);
    expect(homeForRole(UserRole.owner), AppRouter.ownerDashboard);
  });
}
