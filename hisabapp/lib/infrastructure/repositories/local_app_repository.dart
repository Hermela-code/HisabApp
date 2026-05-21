import '../../domain/entities/branch.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/app_repository.dart';
import '../data_sources/in_memory_data_store.dart';

class LocalAppRepository implements AppRepository {
  final InMemoryDataStore _dataStore;

  LocalAppRepository(this._dataStore);

  @override
  Future<void> addBranch(Branch branch) async {
    _dataStore.branches.add(branch);
  }

  @override
  Future<void> addProduct(Product product) async {
    _dataStore.products.add(product);
  }

  @override
  Future<List<Branch>> getBranches() async {
    return List.unmodifiable(_dataStore.branches);
  }

  @override
  Future<List<Product>> getProducts(int branchId) async {
    return _dataStore.products.where((product) => product.branchId == branchId).toList();
  }

  @override
  Future<List<Sale>> getSales(int branchId) async {
    return _dataStore.sales.where((sale) => sale.branchId == branchId).toList();
  }

  @override
  Future<User?> login(String username, String password) async {
    try {
      return _dataStore.users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> registerBusiness(String businessName, String businessType) async {
    // In-memory store does not persist business details separately.
    // This method exists to satisfy the domain repository interface.
  }

  @override
  Future<void> recordSale(Sale sale) async {
    _dataStore.sales.add(sale);
    final index = _dataStore.products.indexWhere((product) => product.id == sale.productId);
    if (index != -1) {
      final existing = _dataStore.products[index];
      _dataStore.products[index] = existing.copyWith(stock: existing.stock - sale.quantity);
    }
  }

  @override
  Future<void> signUp(User user) async {
    _dataStore.users.add(user);
  }
}
