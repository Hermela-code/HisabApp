class Staff {
  final int id;
  final String name;
  final String phone;
  final int branchId;

  Staff({
    required this.id,
    required this.name,
    this.phone = '',
    required this.branchId,
  });
}
