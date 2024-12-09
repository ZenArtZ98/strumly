import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:strumly/features/auth/domain/entities/user_profile.dart';
import 'package:strumly/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  UserRepositoryImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final Map<String, dynamic> data = {
      'username': profile.username,
      'description': profile.description,
    };

    if (profile.avatarUrl != null) {
      data['avatarUrl'] = profile.avatarUrl;
    }

    if (profile.activityData.isNotEmpty) {
      data['activityData'] = profile.activityData;
    }

    await firestore.collection('users').doc(profile.uid).set(data, SetOptions(merge: true));
  }

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      // Создаем новый профиль
      final newUserProfile = UserProfile(
        uid: uid,
        username: 'New User',
        description: '',
        avatarUrl: null,
        activityData: [],
        stats: {},
      );

      await firestore.collection('users').doc(uid).set({
        'username': newUserProfile.username,
        'description': newUserProfile.description,
        'avatarUrl': newUserProfile.avatarUrl,
        'activityData': newUserProfile.activityData,
        'stats': newUserProfile.stats,
      });

      return newUserProfile;
    }

    final data = doc.data()!;
    return UserProfile(
      uid: uid,
      username: data['username'] ?? 'Unknown User',
      description: data['description'] ?? '',
      avatarUrl: data['avatarUrl'],
      activityData: (data['activityData'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      stats: Map<String, String>.from(data['stats'] ?? {}),
    );
  }

  Future<String> uploadAvatar(String uid, String filePath) async {
    final ref = storage.ref().child('avatars/$uid');
    final task = ref.putFile(File(filePath));
    final snapshot = await task.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }
}
