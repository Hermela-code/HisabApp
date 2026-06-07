/// Electronics category labels used in inventory and record-sale flows.
class ProductCategories {
  static const mobile = 'Mobile';
  static const tv = 'TV';
  static const other = 'Other';
  static const List<String> all = [mobile, tv, other];
}

class Product {
  final int id;
  final String name;
  final String model;
  final String specification;
  final String category;
  final int stock;
  final int unitPrice;
  final int costPrice;
  final int branchId;

  Product({
    required this.id,
    required this.name,
    required this.model,
    required this.specification,
    this.category = ProductCategories.mobile,
    required this.stock,
    required this.unitPrice,
    this.costPrice = 0,
    required this.branchId,
  });

  String get electronicsType =>
      category.trim().isEmpty ? ProductCategories.mobile : category;

  Product copyWith({
    int? id,
    String? name,
    String? model,
    String? specification,
    String? category,
    int? stock,
    int? unitPrice,
    int? costPrice,
    int? branchId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      specification: specification ?? this.specification,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      branchId: branchId ?? this.branchId,
    );
  }
}
