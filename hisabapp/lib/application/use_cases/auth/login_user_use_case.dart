import '../../../domain/entities/user.dart';
import '../../../domain/repositories/app_repository.dart';

class LoginUserUseCase {
  final AppRepository repository;

  LoginUserUseCase(this.repository);

  Future<User?> execute(String username, String password) {
    return repository.login(username, password);
  }
}
