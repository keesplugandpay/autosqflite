<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# AutoSqfLite

A simple, automatic SQLite database helper for Flutter that handles table creation and schema updates dynamically. No more writing CREATE TABLE statements or managing migrations manually!

## Features

- 🚀 Automatic table creation from Dart objects
- 📊 Dynamic schema updates when new fields are added
- 🔄 Automatic type mapping between Dart and SQLite
- 💾 Simple CRUD operations
- 🛠 Zero configuration required
- 🎯 Type-safe operations
- 🔒 Password protection for databases
- 🔄 Support for nested objects with foreign key relationships
- 📅 Automatic DateTime handling

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  autosqflite: ^1.0.0
```


## Usage

### Basic Setup

```dart
// Create an instance of AutoSqfLite
final db = AutoSqfLite(databaseName: 'my_app');
```

### Database Encryption

To use an encrypted database, simply provide a password when creating the AutoSqfLite instance:

```dart
final db = AutoSqfLite(
  databaseName: 'my_app',
  password: 'your_secure_password'
);
```

**Important Security Notes:**
- Store your encryption password securely (e.g., using flutter_secure_storage)
- The password must be provided consistently for all database operations
- If the password is lost, the database cannot be recovered
- Consider implementing proper key management in your production environment

### Creating Models

```dart
class Todo {
  final int? id;
  final String title;
  final bool completed;
  final DateTime createdAt;

  Todo({
    this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
  });

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt,
    };
  }

  // Create from Map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      completed: map['completed'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}
```

### CRUD Operations

```dart
// Insert
await db.insert('todos', todo.toMap());

// Get all records
final todos = await db.getAll('todos');

// Get single record
final todo = await db.get('todos', 1);

// Update
await db.update('todos', todo.toMap(), 1);

// Delete
await db.delete('todos', 1);
```

### Automatic Schema Updates

AutoSqfLite automatically handles:
- Table creation when you first insert data
- Adding new columns when your model evolves
- Type mapping between Dart and SQLite

```dart
// Original model
class User {
  String name;
  int age;
}

// Later, add new fields - AutoSqfLite handles it automatically!
class User {
  String name;
  int age;
  String email;    // New field
  bool isActive;   // New field
}
```

## Supported Types

AutoSqfLite automatically maps between Dart and SQLite types:

| Dart Type | SQLite Type | Storage Format |
|-----------|-------------|----------------|
| int       | INTEGER     | Direct         |
| double    | REAL        | Direct         |
| String    | TEXT        | Direct         |
| bool      | INTEGER     | 0 or 1         |
| DateTime  | INTEGER     | Milliseconds since epoch with '_datetime' suffix |

### DateTime Handling

DateTime fields are automatically:
- Stored as milliseconds since epoch
- Suffixed with '_datetime' in the database
- Automatically converted back to DateTime when retrieved
- No manual conversion needed in your models

```dart
// Example with DateTime
class Event {
  final DateTime createdAt;
  
  // AutoSqfLite handles the DateTime conversion automatically
  // The field will be stored as 'createdAt_datetime' in the database
  Event({required this.createdAt});
}
```

## Example

Here's a complete example using AutoSqfLite in a Todo app:

```dart
class TodoService {
  final AutoSqfLite _db;
  static const String tableName = 'todos';

  TodoService() : _db = AutoSqfLite(databaseName: 'todo_app');

  Future<void> addTodo(Todo todo) async {
    await _db.insert(tableName, todo.toMap());
  }

  Future<List<Todo>> getAllTodos() async {
    final maps = await _db.getAll(tableName);
    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  Future<void> updateTodo(Todo todo) async {
    await _db.update(tableName, todo.toMap(), todo.id!);
  }

  Future<void> deleteTodo(int id) async {
    await _db.delete(tableName, id);
  }
}
```

## Additional Features

- Automatic handling of boolean values (converts to 0/1 for SQLite)
- DateTime conversion to milliseconds for storage
- Null-safe operations
- Automatic table existence checking

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built on top of the excellent [sqflite_sqlcipher](https://pub.dev/packages/sqflite_sqlcipher) package
- Inspired by the need for simpler database operations in Flutter

## Support

If you find this package helpful, please give it a like on [pub.dev](https://pub.dev/packages/autosqflite) and star our [GitHub repository](https://github.com/keesplugandpay/autosqflite)!

### DateTime and Nested Objects

AutoSqfLite provides enhanced support for DateTime fields and nested objects:

```dart
// Example with DateTime and nested object
class Order {
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from Map
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}
```
