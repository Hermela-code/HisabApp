import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/models/daily_report.dart';
import '../../application/providers/session_provider.dart';
import '../../features/Auth/login/login.dart';
import '../../features/Auth/registration/attribute.dart';
import '../../features/Auth/registration/bussiness_type.dart';
import '../../features/Auth/registration/select_role.dart';
import '../../features/Auth/signup/signup.dart';
import '../../features/Landing_page/landing.dart';
import '../../features/cashier/branch_cost.dart';
import '../../features/cashier/cashier_dashboard.dart';
import '../../features/cashier/daily_sales.dart';
import '../../features/cashier/export_archive.dart';
import '../../features/cashier/inventory.dart';
import '../../features/cashier/record_sale.dart';
import '../../features/cashier/staff_performance.dart';
import '../../features/owner/branch_detail.dart';
import '../../features/owner/branches.dart';
import '../../features/owner/export_archive.dart';
import '../../features/owner/owner_dashboard.dart';
import '../../features/owner/owner_record_sale.dart';
import '../../features/settings/edit_product_attributes.dart';
import '../../features/settings/settings_page.dart';
import '../../features/widgets/modals/report.dart';
import 'app_router.dart';
import 'auth_redirect.dart';
import 'router_refresh_notifier.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: AppRouter.landing,
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(sessionProvider);
      return resolveAuthRedirect(
        user: user,
        matchedLocation: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: AppRouter.landing,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRouter.selectRole,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRouter.businessType,
        builder: (context, state) => BusinessTypeScreen(role: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRouter.attribute,
        builder: (context, state) => ProductAttributesScreen(role: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRouter.signup,
        builder: (context, state) => SignupScreen(role: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppRouter.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.cashierDashboard,
        builder: (context, state) => const CashierDashboard(),
      ),
      GoRoute(
        path: AppRouter.cashierInventory,
        builder: (context, state) => const Inventory(),
      ),
      GoRoute(
        path: AppRouter.cashierRecordSale,
        builder: (context, state) => const RecordSalePage(),
      ),
      GoRoute(
        path: AppRouter.cashierDailySales,
        builder: (context, state) => const DailySales(),
      ),
      GoRoute(
        path: AppRouter.cashierBranchCost,
        builder: (context, state) => const BranchCost(),
      ),
      GoRoute(
        path: AppRouter.cashierExportArchive,
        builder: (context, state) => const ExportArchive(),
      ),
      GoRoute(
        path: AppRouter.cashierStaff,
        builder: (context, state) => const StaffPerformance(),
      ),
      GoRoute(
        path: AppRouter.ownerDashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRouter.branchDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            final branchMap = extra['branch'] is Map
                ? Map<String, String>.from(
                    (extra['branch'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                  )
                : Map<String, String>.fromEntries(
                    extra.entries
                        .where((e) => !const {'products', 'sales', 'costs', 'staff'}.contains(e.key))
                        .map((e) => MapEntry(e.key.toString(), e.value.toString())),
                  );
            return BranchDetailPage(
              data: branchMap,
              products: (extra['products'] as List?)
                  ?.map((e) => Map<String, String>.from(
                        (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                      ))
                  .toList(),
              sales: (extra['sales'] as List?)
                  ?.map((e) => Map<String, String>.from(
                        (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                      ))
                  .toList(),
              costs: (extra['costs'] as List?)
                  ?.map((e) => Map<String, String>.from(
                        (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                      ))
                  .toList(),
              staff: (extra['staff'] as List?)
                  ?.map((e) => Map<String, String>.from(
                        (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                      ))
                  .toList(),
              initialTab: extra['activeTab']?.toString(),
            );
          }
          return BranchDetailPage(
            data: extra is Map<String, String> ? extra : {},
          );
        },
      ),
      GoRoute(
        path: AppRouter.ownerRecordSale,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            return OwnerRecordSalePage(
              branchData: Map<String, String>.from(
                (extra['branch'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
              ),
              stockProducts: (extra['products'] as List?)
                      ?.map((e) => Map<String, String>.from(
                            (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                          ))
                      .toList() ??
                  const [],
              staffMaps: (extra['staff'] as List?)
                      ?.map((e) => Map<String, String>.from(
                            (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                          ))
                      .toList() ??
                  const [],
              salesMaps: (extra['sales'] as List?)
                      ?.map((e) => Map<String, String>.from(
                            (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                          ))
                      .toList() ??
                  const [],
              costsMaps: (extra['costs'] as List?)
                      ?.map((e) => Map<String, String>.from(
                            (e as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
                          ))
                      .toList() ??
                  const [],
            );
          }
          return const OwnerRecordSalePage();
        },
      ),
      GoRoute(
        path: AppRouter.ownerBranches,
        builder: (context, state) => const BranchPage(),
      ),
      GoRoute(
        path: AppRouter.ownerExports,
        builder: (context, state) => const ExportArchivePage(),
      ),
      GoRoute(
        path: AppRouter.ownerReport,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is ReportNavigationArgs) {
            return ReportPage(
              report: extra.report,
              returnRoute: extra.returnRoute,
              source: extra.source,
            );
          }
          if (extra is DailyReportArchive) {
            return ReportPage(report: extra);
          }
          final today = DateTime.now().toIso8601String().split('T').first;
          return ReportPage(
            report: DailyReportArchive(
              id: 0,
              date: today,
              branchName: 'No data',
              income: 0,
              operationalCost: 0,
              totalUnits: 0,
              distinctProducts: 0,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRouter.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRouter.editProductAttributes,
        builder: (context, state) => const EditProductAttributesPage(),
      ),
    ],
  );
});
