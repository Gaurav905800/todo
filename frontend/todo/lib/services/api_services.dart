import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo/models/todo.dart';

class ApiServices {
  final String baseUrl = 'http://localhost:8000/api/task';

  Future<List<Todos>> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        final todoData = Todo.fromJson(decodedJson);
        return todoData.todos ?? [];
      } else {
        throw Exception('Failed to load todos from server');
      }
    } catch (e) {
      throw Exception('Error fetching todos: $e');
    }
  }

  Future<void> addTodo(Todos todo) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(todo.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add todo to server');
      }
    } catch (e) {
      throw Exception('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(Todos todo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${todo.sId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(todo.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update todo on server');
      }
    } catch (e) {
      throw Exception('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo from server');
      }
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }
}
