import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthUser;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthUser.FirebaseAuth firebaseAuth;

  AuthRepositoryImpl(this.firebaseAuth);

  @override
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final FirebaseAuthUser.User firebaseUser = userCredential.user!;
      return User(id: firebaseUser.uid, email: firebaseUser.email!);
    } catch (e) {
      throw Exception('Ошибка при входе: $e');
    }
  }

  @override
  Future<User> register(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final FirebaseAuthUser.User firebaseUser = userCredential.user!;
      return User(id: firebaseUser.uid, email: firebaseUser.email!);
    } catch (e) {
      throw Exception('Ошибка при регистрации: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Ошибка при выходе: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final FirebaseAuthUser.User? firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser != null) {
        return User(id: firebaseUser.uid, email: firebaseUser.email!);
      }
      return null;
    } catch (e) {
      throw Exception('Ошибка получения текущего пользователя: $e');
    }
  }
}
