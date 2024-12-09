import 'package:strumly/features/auth/domain/entities/user_profile.dart';
import '../repositories/user_repository.dart';

class GetUserProfile {
  final UserRepository repository;

  GetUserProfile(this.repository);

  Future<UserProfile> call(String uid) async {
    return repository.getUserProfile(uid);
  }
}
