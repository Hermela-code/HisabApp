import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';

// State notifier for managing current user session
class SessionNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}

// Simple provider for storing the current user session
final sessionProvider = NotifierProvider<SessionNotifier, User?>(
  SessionNotifier.new,
);

// Helper getter for current user ID
final currentUserProvider = Provider<int?>((ref) {
  return ref.watch(sessionProvider)?.id;
});

// Helper getter for current branch ID
final currentBranchIdProvider = Provider<int>((ref) {
  return ref.watch(sessionProvider)?.branchId ?? 0;
});

// Helper getter for current user role
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(sessionProvider)?.role;
});
