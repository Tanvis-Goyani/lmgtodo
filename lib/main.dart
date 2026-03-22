import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lmgtodo/constants/app_colors.dart';
import 'package:lmgtodo/models/todo_model.dart';
import 'package:lmgtodo/pages/login_page.dart';
import 'package:lmgtodo/repository/todo_repository.dart';
import 'package:lmgtodo/repository/user_repository.dart';
import 'package:lmgtodo/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/todo/todo_bloc.dart';
import 'bloc/todo/todo_event.dart';
import 'pages/todo_list_page.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());

    final repo = TodoRepository();
    await repo.init();
    await NotificationService.instance.init();
    runApp(MyApp(repository: repo));
  } catch (e) {
    debugPrint(e.toString());
  }
}

class MyApp extends StatelessWidget {
  final TodoRepository repository;
  const MyApp({super.key, required this.repository});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(userRepository: UserRepository()),
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData) {
              return BlocProvider(
                create: (_) =>
                    TodoBloc(repository: repository)..add(LoadTodos()),
                child: const TodoListPage(),
              );
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
