import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(String email, String password) {
    return repository.register(email, password);
  }
}
