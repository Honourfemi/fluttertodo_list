import 'package:flutter/material.dart';
import 'package:fluttertodo_list/models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter("hive_box");
  await Hive.openBox('tasks');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter todo app',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Box taskBox = Hive.box('tasks');
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      final newTask = Task(
        todo: _controller.text,
        timeStamp: DateTime.now(),
        isDone: false,
      );
      taskBox.add(newTask.toMap());
      _controller.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF), // 🔵 background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Todos',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A), // 🔵 title
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ValueListenableBuilder(
                  valueListenable: taskBox.listenable(),
                  builder: (context, Box box, _) {
                    final List allTasks = box.values.toList();
                    final activeTasks =
                    allTasks.where((t) => !t['isDone']).toList();
                    final completedTasks =
                    allTasks.where((t) => t['isDone']).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activeTasks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildTaskList(activeTasks, box),
                          const SizedBox(height: 32),
                        ] else ...[
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                "No tasks yet!",
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],

                        if (completedTasks.isNotEmpty) ...[
                          const Text(
                            "Completed",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildTaskList(
                            completedTasks,
                            box,
                            isCompletedSection: true,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your task here",
                        hintStyle:
                        const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFE0ECFF), // 🔵 input bg
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color(0xFF60A5FA), // 🔵 border
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB), // 🔵 focus
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _addTask,
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB), // 🔵 add button
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List tasks, Box box,
      {bool isCompletedSection = false}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final taskMap = tasks[index];
        final task = Task.fromMap(Map<String, dynamic>.from(taskMap));
        final int originalIndex = box.values.toList().indexOf(taskMap);

        String formattedTime =
            "${task.timeStamp.hour.toString().padLeft(2, '0')}:${task.timeStamp.minute.toString().padLeft(2, '0')}";

        return ListTile(
          onTap: () {
            task.isDone = !task.isDone;
            box.putAt(originalIndex, task.toMap());
          },
          leading: Icon(
            task.isDone ? Icons.check_circle : Icons.circle_outlined,
            color:
            task.isDone ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
            size: 32,
          ),
          title: Text(
            task.todo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: task.isDone
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF1E3A8A),
            ),
          ),
          subtitle: Text(
            formattedTime,
            style: TextStyle(
              color: task.isDone
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF64748B),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFDC2626), // 🔴 delete
            ),
            onPressed: () => box.deleteAt(originalIndex),
          ),
        );
      },
    );
  }
}