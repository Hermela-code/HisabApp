import '../entities/branch.dart';
import '../entities/branch_cost.dart';
import '../entities/product.dart';
import '../entities/report.dart';
import '../entities/sale.dart';
import '../entities/staff.dart';
import '../entities/user.dart';

abstract class AppRepository {
  Future<void> registerBusiness(String businessName, String businessType);
  Future<void> signUp(User user);
  Future<User?> login(String username, String password);

  Future<void> addBranch(Branch branch);
  Future<List<Branch>> getBranches();

  Future<List<String>> getProductAttributes();
  Future<void> saveProductAttributes(List<String> attributes);

  Future<void> addProduct(Product product);
  Future<void> deleteProduct(int productId);
  Future<List<Product>> getProducts(int branchId);

  Future<void> addStaff(Staff staff);
  Future<void> deleteStaff(int staffId);
  Future<List<Staff>> getStaff(int branchId);

  Future<void> addBranchCost(BranchCost cost);
  Future<void> deleteBranchCost(int costId);
  Future<List<BranchCost>> getBranchCosts(int branchId);

  Future<void> recordSale(Sale sale);
  Future<List<Sale>> getSales(int branchId);

  Future<void> addReport(Report report);
  Future<List<Report>> getReports();
  Future<void> markReportDeposited(int reportId);
}
