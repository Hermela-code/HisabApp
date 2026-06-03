enum UserRole { owner, cashier }

class User {
  final int id;
  final String username;
  final String password;
  final UserRole role;
  final int companyId;
  final int? branchId;

  const User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.companyId,
    this.branchId,
  });

  User copyWith({
    int? id,
    String? username,
    String? password,
    UserRole? role,
    int? companyId,
    int? branchId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
    );
  }
}
