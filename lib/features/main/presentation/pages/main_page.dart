import 'package:flutter/material.dart';
import '../widgets/drawer_menu.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
      ),
      drawer: const DrawerMenu(), // Боковое меню
      body: Center(
        child: Text(
          'Добро пожаловать!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
