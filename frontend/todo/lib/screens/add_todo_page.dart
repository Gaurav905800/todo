// lib/screens/add_todo_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/bloc/todo_bloc.dart';
import 'package:todo/models/todo.dart';

enum Priority { low, medium, high }

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key, this.todo});

  final Todos? todo;

  @override
  // ignore: library_private_types_in_public_api
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCompleted = false;
  Priority _priority = Priority.medium;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _isEditing = true;
      _titleController.text = widget.todo!.title ?? '';
      _descriptionController.text = widget.todo!.description ?? '';
      _isCompleted = widget.todo!.completed ?? false;
      _priority = _parsePriority(widget.todo!.priority);
    }
  }

  Priority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'low':
        return Priority.low;
      default:
        return Priority.medium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BlocListener<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TodoLoaded) {
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task Title',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).hintColor)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text('Description',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).hintColor)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter description (optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 4,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Priority',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700])),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPriorityChip(Priority.low, 'Low', Colors.green),
                    const SizedBox(width: 8),
                    _buildPriorityChip(
                        Priority.medium, 'Medium', Colors.orange),
                    const SizedBox(width: 8),
                    _buildPriorityChip(Priority.high, 'High', Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('Completed',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700])),
                    const Spacer(),
                    Switch(
                      value: _isCompleted,
                      onChanged: (value) =>
                          setState(() => _isCompleted = value),
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Update Task' : 'Save Task',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).cardColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(Priority priority, String text, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = priority),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _priority == priority
                ? color.withOpacity(0.2)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _priority == priority ? color : Colors.grey.shade300,
              width: _priority == priority ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: _priority == priority ? color : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final todo = Todos(
        sId: widget.todo?.sId,
        title: _titleController.text,
        description: _descriptionController.text,
        completed: _isCompleted,
        priority: _priority.toString().split('.').last,
      );

      if (_isEditing) {
        context.read<TodoBloc>().add(UpdateTodo(todo));
      } else {
        context.read<TodoBloc>().add(AddTodo(todo));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Task updated successfully'
              : 'Task saved successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
