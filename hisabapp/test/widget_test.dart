import 'package:flutter_test/flutter_test.dart';
import 'package:hisabapp/core/navigation/auth_redirect.dart';
import 'package:hisabapp/domain/entities/user.dart';

void main() {
  test('auth redirect smoke check', () {
    expect(
      resolveAuthRedirect(user: null, matchedLocation: '/cashier-dashboard'),
      '/login',
    );
    expect(
      homeForRole(UserRole.owner),
      '/owner-dashboard',
    );
  });
}
