import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:hisab_server/controllers/auth_controller.dart';
import 'package:hisab_server/controllers/settings_controller.dart';
import 'package:hisab_server/controllers/branch_controller.dart';
import 'package:hisab_server/controllers/product_controller.dart';
import 'package:hisab_server/controllers/sales_controller.dart';
import 'package:hisab_server/controllers/staff_controller.dart';
import 'package:hisab_server/controllers/branchcost_controller.dart';
import 'package:hisab_server/controllers/daily_report_controller.dart';

void main() async {
  final authCtrl = AuthController();
  final settingsCtrl = SettingsController();
  final branchCtrl = BranchController();
  final productCtrl = ProductController();
  final salesCtrl = SalesController();
  final staffCtrl = StaffController();
  final branchCostCtrl = BranchCostController();
  final reportCtrl = DailyReportController();

  final router = Router()
    // --- Onboarding & Auth ---
    ..post('/register-business', authCtrl.registerBusiness)
    ..post('/setup/define-attributes', settingsCtrl.defineProductAttributes)
    ..post('/signup', authCtrl.signUp)
    ..post('/login', authCtrl.login)

    // --- Branch Management ---
    ..post('/get-branches', branchCtrl.getCompanyBranches)
    ..post('/add-branch', branchCtrl.addBranch)

    // --- Product & Inventory Management ---
    ..post('/add-product', productCtrl.addProduct)
    ..post('/edit-product', productCtrl.editProduct)
    ..post('/get-branch-stock', productCtrl.getBranchProducts)
    ..post('/update-stock', productCtrl.updateStock)
    ..delete('/delete-product', productCtrl.deleteProduct)

    // --- Sales Management ---
    ..post('/record-sale', salesCtrl.recordSale)

    // --- Staff Management ---
    ..post('/add-staff', staffCtrl.addStaff)

    // --- Branch Cost Management ---
    ..post('/add-branch-cost', branchCostCtrl.addCost)
    ..get('/get-branch-costs', branchCostCtrl.getDailyCosts)

    // --- Daily Report & Archive ---
    ..post('/generate-daily-snapshot', reportCtrl.generateSnapshot)
    ..get('/get-archived-reports', reportCtrl.getArchivedReports)
    ..patch('/mark-as-deposited', reportCtrl.markAsDeposited);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final ip = InternetAddress.anyIPv4;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final server = await serve(handler, ip, port);

  print('✅ Server live at: http://${server.address.address}:${server.port}');
}
