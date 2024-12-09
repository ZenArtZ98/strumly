import 'package:strumly/features/auth/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<void> updateProfile(UserProfile profile);
  Future<UserProfile> getUserProfile(String uid);
}
