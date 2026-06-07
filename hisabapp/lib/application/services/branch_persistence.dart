import '../../domain/entities/branch.dart';
import '../../domain/entities/branch_cost.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/repositories/app_repository.dart';
import '../mappers/branch_data_mapper.dart';
import '../providers/owner_exports_provider.dart';

/// Loads and persists owner branch data through [AppRepository].
class BranchPersistence {
  static Future<int> resolveBranchId(AppRepository repo, String branchName) async {
    if (branchName.isEmpty) return 0;
    final branches = await repo.getBranches();
    for (final branch in branches) {
      if (branch.name.toLowerCase() == branchName.toLowerCase()) {
        return branch.id;
      }
    }
    final nextId = branches.isEmpty
        ? 1
        : branches.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
    await repo.addBranch(Branch(
      id: nextId,
      name: branchName,
      companyId: 1,
      location: '',
      cashier: '',
    ));
    return nextId;
  }

  static Future<OwnerBranchSession> loadSession(
    AppRepository repo,
    String branchName,
    Map<String, String> branchData,
  ) async {
    final branchId = await resolveBranchId(repo, branchName);
    if (branchId == 0) {
      return OwnerBranchSession(branchData: branchData);
    }

    final products = await repo.getProducts(branchId);
    final sales = await repo.getSales(branchId);
    final costs = await repo.getBranchCosts(branchId);
    final staff = await repo.getStaff(branchId);

    final productMaps = products.map(BranchDataMapper.productToMap).toList();
    final saleMaps = sales.map(BranchDataMapper.saleToMap).toList();
    final enrichedSales = BranchDataMapper.enrichSales(saleMaps, productMaps);

    return OwnerBranchSession(
      branchData: branchData,
      products: productMaps,
      sales: enrichedSales,
      costs: costs.map(BranchDataMapper.costToMap).toList(),
      staff: staff.map((s) => BranchDataMapper.staffToMap(s, sales: sales)).toList(),
    );
  }

  static Future<void> persistProduct(AppRepository repo, Product product) async {
    await repo.addProduct(product);
  }

  static Future<void> persistStaff(AppRepository repo, Staff staff) async {
    await repo.addStaff(staff);
  }

  static Future<void> persistCost(AppRepository repo, BranchCost cost) async {
    await repo.addBranchCost(cost);
  }

  static Future<void> persistSale(AppRepository repo, Sale sale) async {
    await repo.recordSale(sale);
  }

  static Future<void> deleteProduct(AppRepository repo, int id) async {
    await repo.deleteProduct(id);
  }

  static Future<void> deleteStaff(AppRepository repo, int id) async {
    await repo.deleteStaff(id);
  }

  static Future<void> deleteCost(AppRepository repo, int id) async {
    await repo.deleteBranchCost(id);
  }
}
