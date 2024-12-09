import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: const Text(
              'Strumly',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Главная'),
            onTap: () {
              Navigator.pop(context); // Закрыть меню
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Профиль'),
            onTap: () {
              // TODO: Добавить переход
            },
          ),
          ListTile(
            leading: const Icon(Icons.queue_music),
            title: const Text('Мои плейлисты'),
            onTap: () {
              // TODO: Добавить переход
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Активность'),
            onTap: () {
              // TODO: Добавить переход
            },
          ),
          ListTile(
            leading: const Icon(Icons.recommend),
            title: const Text('Рекомендации'),
            onTap: () {
              // TODO: Добавить переход
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Выход'),
            onTap: () {
              // TODO: Добавить логику выхода
            },
          ),
        ],
      ),
    );
  }
}
