import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase
import 'package:shared_preferences/shared_preferences.dart'; // Для локального хранения
import 'package:strumly/features/auth/data/repositories/user_repository_impl.dart';
import 'package:strumly/features/auth/domain/usecases/get_user_profile.dart';
import 'package:strumly/features/auth/domain/usecases/update_user_profile.dart';
import 'package:strumly/features/auth/presentation/blocs/user_profile_bloc.dart';
import 'features/playlists/presentation/pages/playlists_page.dart';
import 'features/playlists/presentation/providers/playlist_provider.dart';
import 'features/metronome/presentation/pages/metronome_page.dart';
import 'features/auth/presentation/pages/login_page.dart'; // Экран авторизации
import 'features/auth/presentation/pages/register_page.dart'; // Экран регистрации
import 'features/auth/presentation/pages/user_profile_page.dart'; // Страница профиля
import 'firebase_options.dart'; // FlutterFire CLI
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Инициализация репозиториев
  final userRepository = UserRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
  final authRepository = AuthRepositoryImpl(FirebaseAuth.instance);

  // Проверка сохранённого пользователя
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userId = prefs.getString('userId'); // ID пользователя, сохранённого локально

  runApp(
    MultiProvider(
      providers: [
        Provider<GetUserProfile>(
          create: (_) => GetUserProfile(userRepository),
        ),
        Provider<UpdateUserProfile>(
          create: (_) => UpdateUserProfile(userRepository),
        ),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()), // Провайдер для плейлистов
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(authRepository),
            registerUseCase: RegisterUseCase(authRepository),
          ),
        ),
        BlocProvider<UserProfileBloc>(
          create: (context) => UserProfileBloc(
            getUserProfile: context.read<GetUserProfile>(),
            updateUserProfile: context.read<UpdateUserProfile>(),
          ),
        ),
      ],
      child: MyApp(
        initialRoute: isLoggedIn && userId != null ? '/profile/$userId' : '/login',
      ),
    ),
  );
}


class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strumly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: initialRoute, // Динамическая начальная маршрутизация
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name != null && settings.name!.startsWith('/profile')) {
          final userId = settings.name!.split('/').last; // Извлечение userId
          return MaterialPageRoute(
            builder: (context) => UserProfilePage(userId: userId),
          );
        }
        // Стандартные маршруты
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/playlists':
            return MaterialPageRoute(builder: (_) => const PlaylistsPage());
          // case '/activity':
          //   return MaterialPageRoute(builder: (_) => const ActivityPage());
          case '/metronome':
            return MaterialPageRoute(builder: (_) => const MetronomePage());
          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}
