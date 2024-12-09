import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Проверка авторизован ли пользователь

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Заголовок меню
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Text(
              'Меню',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Элементы меню
          if (user != null) // Показываем профиль только если пользователь авторизован
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Профиль'),
              onTap: () {
                Navigator.pushNamed(context, '/activity');
              },
            )
          else // Если не авторизован, показываем ссылку на авторизацию
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Авторизация'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ListTile(
            leading: const Icon(Icons.library_music),
            title: const Text('Мои плейлисты'),
            onTap: () {
              Navigator.pushNamed(context, '/playlists');
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_music),
            title: const Text('Метроном'),
            onTap: () {
              Navigator.pushNamed(context, '/metronome');
            },
          ),
          ListTile(
            leading: const Icon(Icons.recommend),
            title: const Text('Рекомендации'),
            onTap: () {
              Navigator.pushNamed(context, '/recommendations');
            },
          ),
          if (user != null) // Показываем кнопку выхода только для авторизованных пользователей
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выход'),
              onTap: () async {
                await FirebaseAuth.instance.signOut(); // Выход из аккаунта
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // Переход на авторизацию
              },
            ),
        ],
      ),
    );
  }
}
