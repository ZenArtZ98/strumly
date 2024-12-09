class UserProfile {
  final String uid;
  final String username;
  final String? avatarUrl;
  final String description;
  final List<Map<String, dynamic>> activityData;
  final Map<String, String> stats;

  UserProfile({
    required this.uid,
    required this.username,
    this.avatarUrl,
    required this.description,
    required this.activityData,
    required this.stats,
  });

  UserProfile copyWith({
    String? uid,
    String? username,
    String? avatarUrl,
    String? description,
    List<Map<String, dynamic>>? activityData,
    Map<String, String>? stats,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      activityData: activityData ?? this.activityData,
      stats: stats ?? this.stats,
    );
  }
}
