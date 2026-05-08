import 'package:go_router/go_router.dart';
import '../../features/Landing_page/landing.dart';
import '../../features/Auth/registration/select_role.dart';
import '../../features/Auth/registration/bussiness_type.dart';
import '../../features/Auth/registration/attribute.dart';
import '../../features/Auth/signup/signup.dart';
import '../../features/Auth/login/login.dart';
import '../../features/cashier/cashier_dashboard.dart';
import '../../features/owner/owner_dashboard.dart';

class AppRouter {
  static const String landing = '/';
  static const String selectRole = '/select-role';
  static const String businessType = '/business-type';
  static const String attribute = '/attribute';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String cashierDashboard = '/cashier-dashboard';
  static const String ownerDashboard = '/owner-dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: landing,
    routes: [
      GoRoute(
        path: landing,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: selectRole,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: businessType,
        builder: (context, state) => BusinessTypeScreen(role: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: attribute,
        builder: (context, state) => ProductAttributesScreen(role: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => SignupScreen(role: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: cashierDashboard,
        builder: (context, state) => const CashierDashboard(),
      ),
      GoRoute(
        path: ownerDashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}
