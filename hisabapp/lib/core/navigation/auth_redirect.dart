import '../../domain/entities/user.dart';
import 'app_router.dart';

/// Routes that do not require a logged-in user.
const _publicPaths = {
  AppRouter.landing,
  AppRouter.selectRole,
  AppRouter.businessType,
  AppRouter.attribute,
  AppRouter.signup,
  AppRouter.login,
};

/// Routes only accessible when logged in (any role).
const _sharedAuthenticatedPaths = {
  AppRouter.settings,
  AppRouter.editProductAttributes,
  AppRouter.ownerReport,
};

const _cashierPathPrefix = '/cashier';
const _ownerPaths = {
  AppRouter.ownerDashboard,
  AppRouter.branchDetail,
  AppRouter.ownerRecordSale,
  AppRouter.ownerBranches,
  AppRouter.ownerExports,
};

bool isPublicRoute(String path) => _publicPaths.contains(path);

bool isSharedAuthenticatedRoute(String path) =>
    _sharedAuthenticatedPaths.contains(path) || path.startsWith('/settings');

bool isCashierRoute(String path) => path.startsWith(_cashierPathPrefix);

bool isOwnerRoute(String path) => _ownerPaths.contains(path);

String homeForRole(UserRole role) =>
    role == UserRole.cashier ? AppRouter.cashierDashboard : AppRouter.ownerDashboard;

/// Returns a redirect path, or null if navigation is allowed.
String? resolveAuthRedirect({
  required User? user,
  required String matchedLocation,
}) {
  final path = matchedLocation;

  if (user == null) {
    if (isPublicRoute(path)) return null;
    return AppRouter.login;
  }

  // Logged in: send home from marketing/auth screens.
  if (isPublicRoute(path)) {
    return homeForRole(user.role);
  }

  if (isSharedAuthenticatedRoute(path)) return null;

  if (user.role == UserRole.cashier) {
    if (isOwnerRoute(path)) return AppRouter.cashierDashboard;
    return null;
  }

  // Owner
  if (isCashierRoute(path)) return AppRouter.ownerDashboard;
  return null;
}
