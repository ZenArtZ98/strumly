import 'package:strumly/features/auth/domain/entities/user_profile.dart';
import '../repositories/user_repository.dart';

class UpdateUserProfile {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  Future<void> call(UserProfile profile) async {
    return repository.updateProfile(profile);
  }
}
