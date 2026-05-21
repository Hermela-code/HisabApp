import '../entities/branch.dart';
import '../entities/product.dart';
import '../entities/sale.dart';
import '../entities/user.dart';

abstract class AppRepository {
  Future<void> registerBusiness(String businessName, String businessType);
  Future<void> signUp(User user);
  Future<User?> login(String username, String password);
  Future<void> addBranch(Branch branch);
  Future<List<Branch>> getBranches();
  Future<void> addProduct(Product product);
  Future<List<Product>> getProducts(int branchId);
  Future<void> recordSale(Sale sale);
  Future<List<Sale>> getSales(int branchId);
}
