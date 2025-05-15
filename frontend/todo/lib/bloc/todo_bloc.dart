import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/services/api_services.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final ApiServices apiServices;

  TodoBloc({required this.apiServices}) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<SearchTodos>(_onSearchTodos);
  }
  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    try {
      emit(TodoLoading());
      final todos = await apiServices.fetchTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: 'Failed to load todos: $e'));
      if (state is TodoLoaded) {
        emit(state);
      }
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      try {
        await apiServices.addTodo(event.todo);
        emit(TodoLoaded(todos: [...currentState.todos, event.todo]));
      } catch (e) {
        emit(TodoError(message: e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      try {
        await apiServices.updateTodo(event.todo);
        final updatedTodos = currentState.todos
            .map((todo) => todo.sId == event.todo.sId ? event.todo : todo)
            .toList();
        emit(TodoLoaded(todos: updatedTodos));
      } catch (e) {
        emit(TodoError(message: e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      try {
        await apiServices.deleteTodo(event.id);
        final updatedTodos =
            currentState.todos.where((todo) => todo.sId != event.id).toList();
        emit(TodoLoaded(todos: updatedTodos));
      } catch (e) {
        emit(TodoError(message: e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onSearchTodos(
      SearchTodos event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      if (event.query.isEmpty) {
        emit(currentState.copyWith(filteredTodos: currentState.todos));
      } else {
        final filtered = currentState.todos
            .where((todo) =>
                (todo.title
                        ?.toLowerCase()
                        .contains(event.query.toLowerCase()) ??
                    false) ||
                (todo.description
                        ?.toLowerCase()
                        .contains(event.query.toLowerCase()) ??
                    false))
            .toList();
        emit(currentState.copyWith(filteredTodos: filtered));
      }
    }
  }
}
