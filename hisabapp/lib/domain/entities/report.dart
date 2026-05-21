class Report {
  final int id;
  final int branchId;
  final String date;
  final int totalAmount;
  final int totalUnits;
  final int totalProducts;
  final int totalCost;
  bool isDeposited;

  Report({
    required this.id,
    required this.branchId,
    required this.date,
    required this.totalAmount,
    required this.totalUnits,
    required this.totalProducts,
    required this.totalCost,
    this.isDeposited = false,
  });
}
