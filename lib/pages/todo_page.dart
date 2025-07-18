import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/todo_service.dart';
import 'dart:async';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAddTodo() async {
    final title = _titleController.text.trim();
    final text = _controller.text.trim();
    if (title.isEmpty || text.isEmpty) return;

    setState(() => _isLoading = true);

    await TodoService.addTodo(title, text);

    _titleController.clear();
    _controller.clear();
    setState(() => _isLoading = false);
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter title...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter task...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _handleAddTodo,
                          child: const Text('Add'),
                        ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: TodoService.todoStreamWidget()),
        ],
      ),
    );
  }
}
