class Branch {
  final int id;
  final String name;
  final int companyId;
  final String location;
  final String cashier;

  Branch({
    required this.id,
    required this.name,
    required this.companyId,
    this.location = '',
    this.cashier = '',
  });
}
