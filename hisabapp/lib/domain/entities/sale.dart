class Sale {
  final int id;
  final int productId;
  final String productName;
  final String salesperson;
  final int quantity;
  final int unitPrice;
  final int total;
  final DateTime createdAt;
  final int branchId;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.salesperson,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.createdAt,
    required this.branchId,
  });
}
