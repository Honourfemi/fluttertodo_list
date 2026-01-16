class Task {
  String todo;
  DateTime timeStamp;
  bool isDone;

  Task({required this.todo, required this.timeStamp, required this.isDone});

  Map toMap() {
    return {
      'todo': todo,
      'timeStamp': timeStamp.toIso8601String(),
      'isDone': isDone,
    };
  }

  factory Task.fromMap(Map task) {
    return Task(
      todo: task["todo"],
      timeStamp: DateTime.parse(task["timeStamp"]),
      isDone: task["isDone"],
    );
  }
}