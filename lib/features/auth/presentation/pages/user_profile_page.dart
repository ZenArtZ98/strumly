// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:strumly/features/auth/domain/entities/user_profile.dart';
// import '../../domain/usecases/get_user_profile.dart';
// import '../../domain/usecases/update_user_profile.dart';
// import '../blocs/user_profile_bloc.dart';
//
// class UserProfilePage extends StatelessWidget {
//   final String userId;
//
//   const UserProfilePage({Key? key, required this.userId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => UserProfileBloc(
//         getUserProfile: context.read<GetUserProfile>(),
//         updateUserProfile: context.read<UpdateUserProfile>(),
//       )..add(LoadUserProfile(userId)),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Profile'),
//           actions: [
//             PopupMenuButton<String>(
//               onSelected: (value) => _handleMenuAction(context, value),
//               itemBuilder: (context) => const [
//                 PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
//                 PopupMenuItem(value: 'share', child: Text('Share Profile')),
//               ],
//             ),
//           ],
//         ),
//         body: BlocBuilder<UserProfileBloc, UserProfileState>(
//           builder: (context, state) {
//             if (state is UserProfileLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is UserProfileLoaded) {
//               return _buildProfileContent(context, state.profile);
//             } else if (state is UserProfileError) {
//               return Center(child: Text(state.message));
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//     );
//   }
//
//   void _handleMenuAction(BuildContext context, String value) {
//     if (value == 'edit') {
//       _editProfile(context);
//     } else if (value == 'share') {
//       _shareProfile(context);
//     }
//   }
//
//   void _editProfile(BuildContext context) {
//     final state = context.read<UserProfileBloc>().state;
//     if (state is UserProfileLoaded) {
//       final profile = state.profile;
//
//       showDialog(
//         context: context,
//         builder: (context) {
//           final descriptionController =
//           TextEditingController(text: profile.description);
//           final avatarController =
//           TextEditingController(text: profile.avatarUrl);
//
//           return AlertDialog(
//             title: const Text('Edit Profile'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: descriptionController,
//                   decoration: const InputDecoration(labelText: 'Description'),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: avatarController,
//                   decoration: const InputDecoration(labelText: 'Avatar URL'),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   context.read<UserProfileBloc>().add(UpdateUserProfileEvent(
//                     profile.copyWith(
//                       description: descriptionController.text,
//                       avatarUrl: avatarController.text,
//                     ),
//                   ));
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   void _shareProfile(BuildContext context) {
//     final state = context.read<UserProfileBloc>().state;
//     if (state is UserProfileLoaded) {
//       final profile = state.profile;
//       final message = '''
// Check out my profile on Strumly!
// 🎵 ${profile.username} 🎵
//
// - ${profile.stats['songs'] ?? '0'} Songs listened
// - ${profile.stats['time'] ?? '0h'} Total time
// - ${profile.stats['streak'] ?? '0d'} Streak
// - Favorite Artist: ${profile.stats['favorite_artist'] ?? 'Unknown'}
//
// Join me now: https://strumly.app/profile/${profile.uid}
//       ''';
//
//       Share.share(message);
//     }
//   }
//
//   Widget _buildProfileContent(BuildContext context, UserProfile profile) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: profile.avatarUrl != null
//                       ? NetworkImage(profile.avatarUrl!)
//                       : const AssetImage('assets/default_avatar.png') as ImageProvider,
//                   child: profile.avatarUrl == null ? const Icon(Icons.add_a_photo) : null,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   profile.username,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             profile.description ?? 'No description available.',
//             style: const TextStyle(fontSize: 16, color: Colors.black54),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'Activity',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildActivityChart(profile),
//           const SizedBox(height: 24),
//           const Text(
//             'Activity Stats',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildStatsGrid(profile),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActivityChart(UserProfile profile) {
//     return SizedBox(
//       height: 200,
//       child: BarChart(
//         BarChartData(
//           barGroups: profile.activityData
//               .map((activity) => BarChartGroupData(
//             x: activity['day'],
//             barRods: [
//               BarChartRodData(
//                 toY: activity['value'].toDouble(),
//                 color: Colors.blue,
//               ),
//             ],
//           ))
//               .toList(),
//           titlesData: FlTitlesData(
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) => Text(
//                   value.toInt().toString(),
//                   style: const TextStyle(fontSize: 12, color: Colors.black54),
//                 ),
//               ),
//             ),
//             leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//           gridData: FlGridData(show: false),
//           borderData: FlBorderData(show: false),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatsGrid(UserProfile profile) {
//     return GridView.count(
//       crossAxisCount: 2,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: profile.stats.entries.map((stat) {
//         return _StatisticCard(
//           title: stat.value,
//           subtitle: stat.key,
//         );
//       }).toList(),
//     );
//   }
// }
//
// class _StatisticCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//
//   const _StatisticCard({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               subtitle,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.black54,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:strumly/features/auth/domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../blocs/user_profile_bloc.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(
        getUserProfile: context.read<GetUserProfile>(),
        updateUserProfile: context.read<UpdateUserProfile>(),
      )..add(LoadUserProfile(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
                PopupMenuItem(value: 'share', child: Text('Share Profile')),
              ],
            ),
          ],
        ),
        body: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            if (state is UserProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserProfileLoaded) {
              return _buildProfileContent(context, state.profile);
            } else if (state is UserProfileError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    if (value == 'edit') {
      _editProfile(context);
    } else if (value == 'share') {
      _shareProfile(context);
    }
  }

  void _editProfile(BuildContext context) {
    final state = context.read<UserProfileBloc>().state;
    if (state is UserProfileLoaded) {
      final profile = state.profile;

      showDialog(
        context: context,
        builder: (context) {
          final descriptionController =
          TextEditingController(text: profile.description);
          final avatarController =
          TextEditingController(text: profile.avatarUrl);

          return AlertDialog(
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: avatarController,
                  decoration: const InputDecoration(labelText: 'Avatar URL'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<UserProfileBloc>().add(UpdateUserProfileEvent(
                    profile.copyWith(
                      description: descriptionController.text,
                      avatarUrl: avatarController.text,
                    ),
                  ));
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void _shareProfile(BuildContext context) {
    final state = context.read<UserProfileBloc>().state;
    if (state is UserProfileLoaded) {
      final profile = state.profile;
      final message = '''
Check out my profile on Strumly!
🎵 ${profile.username} 🎵

- ${profile.stats['songs'] ?? '0'} Songs listened
- ${profile.stats['time'] ?? '0h'} Total time
- ${profile.stats['streak'] ?? '0d'} Streak
- Favorite Artist: ${profile.stats['favorite_artist'] ?? 'Unknown'}

Join me now: https://strumly.app/profile/${profile.uid}
      ''';

      Share.share(message);
    }
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                  child: profile.avatarUrl == null ? const Icon(Icons.add_a_photo) : null,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.description ?? 'No description available.',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          const Text(
            'Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityChart(profile),
          const SizedBox(height: 24),
          const Text(
            'Activity Stats',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsGrid(profile),
        ],
      ),
    );
  }

  Widget _buildActivityChart(UserProfile profile) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: profile.activityData
              .map((activity) => BarChartGroupData(
            x: activity['day'],
            barRods: [
              BarChartRodData(
                toY: activity['value'].toDouble(),
                color: Colors.blue,
              ),
            ],
          ))
              .toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(UserProfile profile) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: profile.stats.entries.map((stat) {
        return _StatisticCard(
          title: stat.value,
          subtitle: stat.key,
        );
      }).toList(),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatisticCard({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

