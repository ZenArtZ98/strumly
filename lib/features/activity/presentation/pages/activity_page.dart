import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart'; // Для графиков
import 'package:share_plus/share_plus.dart'; // Для шеринга (добавьте в pubspec.yaml)

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? description =
      'I am a website designer and developer with\npixels perfect designers company ltd.';
  String? avatarUrl;

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        final descriptionController = TextEditingController(text: description);
        final avatarController = TextEditingController(text: avatarUrl);

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
                setState(() {
                  description = descriptionController.text.trim();
                  avatarUrl = avatarController.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _shareStatistics() {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email?.split('@').first ?? 'User';
    final message = '''
Check out my profile on Strumly!
🎵 $username 🎵

- 100 Songs listened
- 242h Total time
- 95d Streak
- Favorite Artist: Megadeth

Join me now: https://strumly.app/profile/$username
    ''';

    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email?.split('@').first ?? 'Unknown User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editProfile();
              } else if (value == 'share') {
                _shareStatistics();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Profile'),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Text('Share Profile'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Аватарка и имя пользователя
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl!)
                          : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      username,
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

              // Описание пользователя
              Text(
                description!,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Активность
              const Text(
                'Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // График активности
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      BarChartGroupData(x: 16, barRods: [BarChartRodData(toY: 3, color: Colors.blue)]),
                      BarChartGroupData(x: 17, barRods: [BarChartRodData(toY: 4, color: Colors.blue)]),
                      BarChartGroupData(x: 18, barRods: [BarChartRodData(toY: 2, color: Colors.blue)]),
                      BarChartGroupData(x: 19, barRods: [BarChartRodData(toY: 10, color: Colors.blueAccent)]),
                      BarChartGroupData(x: 20, barRods: [BarChartRodData(toY: 8, color: Colors.grey)]),
                      BarChartGroupData(x: 21, barRods: [BarChartRodData(toY: 9, color: Colors.grey)]),
                      BarChartGroupData(x: 22, barRods: [BarChartRodData(toY: 6, color: Colors.grey)]),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Карточки статистики активности
              const Text(
                'Activity Stats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _StatisticCard(title: '100', subtitle: 'Songs'),
                  _StatisticCard(title: '242h', subtitle: 'Time'),
                  _StatisticCard(title: '95d', subtitle: 'Streak'),
                  _StatisticCard(title: 'Megadeth', subtitle: 'Favorite Artist'),
                ],
              ),
            ],
          ),
        ),
      ),
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
