import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/bloc/theme_bloc.dart';
import 'package:todo/bloc/theme_state.dart';
import 'package:todo/bloc/todo_bloc.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/screens/add_todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoBloc>().add(LoadTodos());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<TodoBloc>().add(SearchTodos(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<TodoBloc, TodoState>(
      listener: (context, state) {
        if (state is TodoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'My Tasks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                final isDark = state.themeMode == ThemeMode.dark;
                return IconButton(
                  icon: Icon(
                      isDark ? Icons.light_mode_sharp : Icons.dark_mode_sharp),
                  onPressed: () {
                    context.read<ThemeBloc>().add(ToggleTheme());
                  },
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? Theme.of(context).cardColor
                        : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                )),
          ),
        ),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state is TodoLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff324644)),
                ),
              );
            } else if (state is TodoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<TodoBloc>().add(LoadTodos()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff324644),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is TodoLoaded) {
              final todos = state.todos;
              if (todos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment,
                          size: 100, color: Colors.grey.shade300),
                      const SizedBox(height: 24),
                      const Text('No tasks yet',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                      const SizedBox(height: 8),
                      const Text('Tap the + button to add a new task',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TodoBloc>().add(LoadTodos());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Dismissible(
                      key: Key(todo.sId ?? '${todo.title}$index'),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color:
                              // ignore: deprecated_member_use
                              Theme.of(context).shadowColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text(
                                'Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        context.read<TodoBloc>().add(DeleteTodo(todo.sId!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"${todo.title}" deleted'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: Checkbox(
                            value: todo.completed ?? false,
                            onChanged: (value) {
                              final updatedTodo = Todos(
                                sId: todo.sId,
                                title: todo.title ?? "No title",
                                description: todo.description,
                                completed: value,
                                priority: todo.priority,
                                iV: todo.iV,
                              );
                              context
                                  .read<TodoBloc>()
                                  .add(UpdateTodo(updatedTodo));
                            },
                            activeColor: const Color(0xff324644),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Text(
                            todo.title ?? 'No title',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: (todo.completed ?? false)
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: (todo.completed ?? false)
                                  ? Theme.of(context).hintColor
                                  : Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                            ),
                          ),
                          subtitle: (todo.description?.isNotEmpty ?? false)
                              ? Text(
                                  todo.description!,
                                  style: TextStyle(
                                    color: (todo.completed ?? false)
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    decoration: (todo.completed ?? false)
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                )
                              : null,
                          trailing: _buildPriorityIndicator(todo.priority),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: context.read<TodoBloc>(),
                                  child: AddTodoPage(todo: todo),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const Center(child: Text('Unknown state'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<TodoBloc>(),
                  child: const AddTodoPage(),
                ),
              ),
            );
          },
          backgroundColor: const Color(0xff324644),
          elevation: 4,
          child: Icon(Icons.add, color: Theme.of(context).cardColor, size: 28),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(String? priority) {
    if (priority == null) return const SizedBox.shrink();

    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
