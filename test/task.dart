class Task {
  final String todo;
  final String timestamp;
  final bool done;

  Task({
    required this.todo,
    required this.timestamp,
    required this.done,
  });

  // Convert a Task object into a Map for Hive
  Map<String, dynamic> toMap() {
    return {
      'todo': todo,
      'timestamp': timestamp,
      'done': done,
    };
  }

  // Create a Task object from a Map retrieved from Hive
  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      todo: map['todo'],
      timestamp: map['timestamp'],
      done: map['done'],
    );
  }
}