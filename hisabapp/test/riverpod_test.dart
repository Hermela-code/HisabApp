import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisabapp/application/providers/session_provider.dart';
import 'package:hisabapp/domain/entities/user.dart';

void main() {
  group('Riverpod SessionProvider & Helpers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      final userSession = container.read(sessionProvider);
      expect(userSession, isNull);
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(currentBranchIdProvider), equals(0));
      expect(container.read(currentUserRoleProvider), isNull);
    });

    test('setUser sets the session user and updates helper providers', () {
      const mockUser = User(
        id: 42,
        username: 'test_cashier',
        password: 'password123',
        role: UserRole.cashier,
        companyId: 101,
        branchId: 5,
      );

      container.read(sessionProvider.notifier).setUser(mockUser);

      final userSession = container.read(sessionProvider);
      expect(userSession, equals(mockUser));
      expect(container.read(currentUserProvider), equals(42));
      expect(container.read(currentBranchIdProvider), equals(5));
      expect(container.read(currentUserRoleProvider), equals(UserRole.cashier));
    });

    test('clearUser clears the session and resets helper providers', () {
      const mockUser = User(
        id: 99,
        username: 'test_owner',
        password: 'password123',
        role: UserRole.owner,
        companyId: 101,
      );

      container.read(sessionProvider.notifier).setUser(mockUser);
      expect(container.read(sessionProvider), equals(mockUser));

      container.read(sessionProvider.notifier).clearUser();

      expect(container.read(sessionProvider), isNull);
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(currentBranchIdProvider), equals(0));
      expect(container.read(currentUserRoleProvider), isNull);
    });
  });
}
