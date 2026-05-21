class Product {
  final int id;
  final String name;
  final String model;
  final String specification;
  final int stock;
  final int unitPrice;
  final int branchId;

  Product({
    required this.id,
    required this.name,
    required this.model,
    required this.specification,
    required this.stock,
    required this.unitPrice,
    required this.branchId,
  });

  Product copyWith({
    int? id,
    String? name,
    String? model,
    String? specification,
    int? stock,
    int? unitPrice,
    int? branchId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      specification: specification ?? this.specification,
      stock: stock ?? this.stock,
      unitPrice: unitPrice ?? this.unitPrice,
      branchId: branchId ?? this.branchId,
    );
  }
}
