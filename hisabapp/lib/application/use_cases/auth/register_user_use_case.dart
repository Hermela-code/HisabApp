import '../../../domain/entities/user.dart';
import '../../../domain/repositories/app_repository.dart';

class RegisterUserUseCase {
  final AppRepository repository;

  RegisterUserUseCase(this.repository);

  Future<void> execute(User user) {
    return repository.signUp(user);
  }
}
