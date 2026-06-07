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
    ..post('/auth/login', authCtrl.login) // Alias for frontend login

    // --- Branch Management ---
    ..post('/get-branches', branchCtrl.getCompanyBranches)
    ..get('/branches', branchCtrl.getCompanyBranches) // Added GET endpoint
    ..post('/add-branch', branchCtrl.addBranch)
    ..put('/branches', branchCtrl.updateBranch)
    ..delete('/branches', branchCtrl.deleteBranch)

    // --- Product & Attributes Setup ---
    ..get('/product-attributes', settingsCtrl.getProductAttributes) // Added GET endpoint

    // --- Product & Inventory Management ---
    ..post('/add-product', productCtrl.addProduct)
    ..post('/edit-product', productCtrl.editProduct)
    ..post('/get-branch-stock', productCtrl.getBranchProducts)
    ..get('/products', productCtrl.getBranchProducts) // Added GET endpoint
    ..get('/branches/<branchId>/products', productCtrl.getBranchProducts) // Added GET endpoint
    ..post('/update-stock', productCtrl.updateStock)
    ..delete('/delete-product', productCtrl.deleteProduct)

    // --- Sales Management ---
    ..post('/record-sale', salesCtrl.recordSale)
    ..get('/branches/<branchId>/sales', salesCtrl.getBranchSales) // Added GET endpoint

    // --- Staff Management ---
    ..post('/add-staff', staffCtrl.addStaff)
    ..get('/staff', staffCtrl.getStaff) // Added GET endpoint
    ..get('/branches/<branchId>/staff', staffCtrl.getStaff) // Added GET endpoint
    ..delete('/delete-staff', staffCtrl.deleteStaff)

    // --- Branch Cost Management ---
    ..post('/add-branch-cost', branchCostCtrl.addCost)
    ..get('/get-branch-costs', branchCostCtrl.getDailyCosts)
    ..get('/branches/<branchId>/costs', branchCostCtrl.getDailyCosts) // Added GET endpoint
    ..delete('/delete-branch-cost', branchCostCtrl.deleteCost)

    // --- Daily Report & Archive ---
    ..post('/generate-daily-snapshot', reportCtrl.generateSnapshot)
    ..get('/get-archived-reports', reportCtrl.getArchivedReports)
    ..get('/reports', reportCtrl.getArchivedReports) // Added GET endpoint
    ..patch('/mark-as-deposited', reportCtrl.markAsDeposited);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final ip = InternetAddress.anyIPv4;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final server = await serve(handler, ip, port);

  print('✅ Server live at: http://${server.address.address}:${server.port}');
}

Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      final headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, X-Requested-With',
      };

      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }

      final response = await handler(request);
      return response.change(headers: headers);
    };
  };
}
