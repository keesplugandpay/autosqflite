import 'package:autosqflite/autosqflite.dart';
import 'package:flutter/material.dart';

import 'todo.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late AutoSqfLite database;
  static const String tableName = 'todos';

  late TextEditingController titleController;
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    database = AutoSqfLite(databaseName: 'todo_db');
    titleController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> addTodoToDatabase(Todo todo) async {
    await database.insert(tableName, todo.toMap());
  }

  Future<List<Todo>> getAllTodosFromDatabase() async {
    final maps = await database.getAll(tableName);
    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  Future<void> updateTodoInDatabase(Todo todo, int id) async {
    await database.update(tableName, todo.toMap(), id);
  }

  Future<void> deleteTodoFromDatabase(int id) async {
    await database.delete(tableName, id);
  }

  void syncTodos() async {
    getAllTodosFromDatabase().then((todos) {
      setState(() {
        this.todos = todos;
      });
    });
  }

  void addTodo() {
    if (titleController.text.isEmpty) return;
    final todo = Todo(
      title: titleController.text,
      completed: false,
      createdAt: DateTime.now(),
    );

    addTodoToDatabase(todo).then((_) {
      syncTodos();
    });

    titleController.clear();
  }

  void toggleTodo(Todo todo) {
    if (todo.id == null) return;
    final newTodo = Todo(
      id: todo.id,
      title: todo.title,
      completed: !todo.completed,
      createdAt: todo.createdAt,
    );

    updateTodoInDatabase(newTodo, todo.id!).then((_) {
      syncTodos();
    });
  }

  void deleteTodo(Todo todo) {
    deleteTodoFromDatabase(todo.id!).then((_) {
      syncTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Todo App'),
        ),
        body: _buildTodoList(),
      ),
    );
  }

  Widget _buildTodoList() => Column(
        children: [
          _buildAddTodoForm(),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) => _buildTodoItem(todos[index]),
            ),
          ),
        ],
      );

  Widget _buildAddTodoForm() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Add a new todo',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: addTodo,
              child: const Text('Add'),
            ),
          ],
        ),
      );

  Widget _buildTodoItem(Todo todo) => ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (bool? value) {
            toggleTodo(todo);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('Created: ${todo.createdAt.toString().split('.').first}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => deleteTodo(todo),
        ),
      );
}
