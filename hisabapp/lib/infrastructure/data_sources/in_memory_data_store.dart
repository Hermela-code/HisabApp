import '../../domain/entities/branch.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/user.dart';

class InMemoryDataStore {
  final List<User> users = [];
  final List<Branch> branches = [];
  final List<Product> products = [];
  final List<Sale> sales = [];
  int _userId = 1;
  int _branchId = 1;
  int _productId = 1;
  int _saleId = 1;

  int nextUserId() => _userId++;
  int nextBranchId() => _branchId++;
  int nextProductId() => _productId++;
  int nextSaleId() => _saleId++;
}
