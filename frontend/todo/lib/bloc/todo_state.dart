part of 'todo_bloc.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todos> todos;
  final List<Todos> filteredTodos;

  const TodoLoaded({
    required this.todos,
    List<Todos>? filteredTodos,
  }) : filteredTodos = filteredTodos ?? todos;

  TodoLoaded copyWith({
    List<Todos>? todos,
    List<Todos>? filteredTodos,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
    );
  }

  @override
  List<Object> get props => [todos, filteredTodos];
}

class TodoError extends TodoState {
  final String message;

  const TodoError({required this.message});

  @override
  List<Object> get props => [message];
}
