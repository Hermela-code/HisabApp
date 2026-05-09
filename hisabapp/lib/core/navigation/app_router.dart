import 'package:go_router/go_router.dart';
import '../../features/Landing_page/landing.dart';
import '../../features/Auth/registration/select_role.dart';
import '../../features/Auth/registration/bussiness_type.dart';
import '../../features/Auth/registration/attribute.dart';
import '../../features/Auth/signup/signup.dart';
import '../../features/Auth/login/login.dart';
import '../../features/cashier/cashier_dashboard.dart';
import '../../features/cashier/inventory.dart';
import '../../features/cashier/record_sale.dart';
import '../../features/cashier/daily_sales.dart';
import '../../features/cashier/branch_cost.dart';
import '../../features/cashier/export_archive.dart';
import '../../features/cashier/staff_performance.dart';
import '../../features/owner/owner_dashboard.dart';
import '../../features/owner/branch_detail.dart';
import '../../features/owner/owner_record_sale.dart';
import '../../features/owner/branches.dart';
import '../../features/owner/export_archive.dart';
import '../../features/widgets/modals/report.dart';

class AppRouter {
  static const String landing = '/';
  static const String selectRole = '/select-role';
  static const String businessType = '/business-type';
  static const String attribute = '/attribute';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String cashierDashboard = '/cashier-dashboard';
  static const String cashierInventory = '/cashier-inventory';
  static const String cashierRecordSale = '/cashier-record-sale';
  static const String cashierDailySales = '/cashier-daily-sales';
  static const String cashierBranchCost = '/cashier-branch-cost';
  static const String cashierExportArchive = '/cashier-export-archive';
  static const String cashierStaff = '/cashier-staff';
  static const String ownerDashboard = '/owner-dashboard';
  static const String branchDetail = '/branch-detail';
  static const String ownerRecordSale = '/owner-record-sale';
  static const String ownerBranches = '/owner-branches';
  static const String ownerExports = '/owner-exports';
  static const String ownerReport = '/owner-report';

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
        path: cashierInventory,
        builder: (context, state) => const Inventory(),
      ),
      GoRoute(
        path: cashierRecordSale,
        builder: (context, state) => const RecordSalePage(),
      ),
      GoRoute(
        path: cashierDailySales,
        builder: (context, state) => const DailySales(),
      ),
      GoRoute(
        path: cashierBranchCost,
        builder: (context, state) => const BranchCost(),
      ),
      GoRoute(
        path: cashierExportArchive,
        builder: (context, state) => const ExportArchive(),
      ),
      GoRoute(
        path: cashierStaff,
        builder: (context, state) => const StaffPerformance(),
      ),
      GoRoute(
        path: ownerDashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: branchDetail,
        builder: (context, state) => const GoroDetailPage(),
      ),
      GoRoute(
        path: ownerRecordSale,
        builder: (context, state) => const OwnerRecordSalePage(),
      ),
      GoRoute(
        path: ownerBranches,
        builder: (context, state) => const BranchPage(),
      ),
      GoRoute(
        path: ownerExports,
        builder: (context, state) => const ExportArchivePage(),
      ),
      GoRoute(
        path: ownerReport,
        builder: (context, state) => const ReportPage(),
      ),
    ],
  );
}
