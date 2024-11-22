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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      completed: map['completed'],
      createdAt: map['createdAt'],
    );
  }
}
