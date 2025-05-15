import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/bloc/theme_state.dart';
import 'package:todo/bloc/todo_bloc.dart';
import 'package:todo/bloc/theme_bloc.dart';
import 'package:todo/screens/home_page.dart';
import 'package:todo/services/api_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiServices>(
          create: (context) => ApiServices(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TodoBloc>(
            create: (context) => TodoBloc(
              apiServices: RepositoryProvider.of<ApiServices>(context),
            )..add(LoadTodos()),
          ),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Todo App',
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: state.themeMode,
              home: const HomePage(),
            );
          },
        ),
      ),
    );
  }
}
