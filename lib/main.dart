import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lmgtodo/constants/app_colors.dart';
import 'package:lmgtodo/models/todo_model.dart';
import 'package:lmgtodo/repository/todo_repository.dart';
import 'bloc/todo_bloc.dart';
import 'bloc/todo_event.dart';
import 'pages/todo_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());

  final repo = TodoRepository();

  await repo.init();
  runApp(MyApp(repository: repo));
}

class MyApp extends StatelessWidget {
  final TodoRepository repository;
  const MyApp({super.key, required this.repository});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
      ),
      home: BlocProvider(
        create: (_) => TodoBloc(repository: repository)..add(LoadTodos()),
        child: const TodoListPage(),
      ),
    );
  }
}
