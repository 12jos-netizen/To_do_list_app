import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task.dart';
import 'package:todo_app/task.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();
  // Open the box (database) named 'tasks'
  await Hive.openBox('tasks');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String content = "";
  late Box taskBox;



  @override
  void initState() {
    super.initState();
    taskBox = Hive.box('tasks');
  }

  // Logic to show the Add Task dialog
  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add a to do"),
          content: TextField(
            onChanged: (value) {
              setState(() {
                content = value;
              });
            },
            decoration: const InputDecoration(hintText: "Enter task name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (content.isNotEmpty) {
                  // Create a task map and add to Hive
                  final newTask = Task(
                    todo: content,
                    timestamp: DateTime.now().toString(),
                    done: false,
                  );
                  taskBox.add(newTask.toMap());

                  content = ""; // Reset
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My To-Do"),
      ),
      body: ValueListenableBuilder(
        // Listens to changes in the Hive box to refresh the list automatically
        valueListenable: taskBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No tasks yet!"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final taskMap = box.getAt(index);
              final task = Task.fromMap(taskMap);

              return ListTile(
                title: Text(task.todo),
                subtitle: Text(task.timestamp),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => box.deleteAt(index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTaskPopup,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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