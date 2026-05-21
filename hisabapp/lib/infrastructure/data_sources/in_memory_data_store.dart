import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';

class InMemoryDataStore {
  final List<User> users = [];
  final List<Branch> branches = [];
  final List<Product> products = [];
  final List<Staff> staff = [];
  final List<Sale> sales = [];
  final List<BranchCost> branchCosts = [];
  final List<Report> reports = [];

  int _userId = 1;
  int _branchId = 1;
  int _productId = 1;
  int _staffId = 1;
  int _saleId = 1;
  int _costId = 1;
  int _reportId = 1;

  int nextUserId() => _userId++;
  int nextBranchId() => _branchId++;
  int nextProductId() => _productId++;
  int nextStaffId() => _staffId++;
  int nextSaleId() => _saleId++;
  int nextCostId() => _costId++;
  int nextReportId() => _reportId++;
}
