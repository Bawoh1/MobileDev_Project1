import 'package:flutter/material.dart';
import '../Data/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> workouts = [];
  int streak = 0;

  @override
  void initState() {
    super.initState();
    loadWorkouts();
    loadStreak();
  }

  Future<void> loadWorkouts() async {
    final data = await DatabaseHelper.instance.getWorkouts();
    setState(() {
      workouts = data;
    });
  }

  Future<void> loadStreak() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    streak = prefs.getInt('streak') ?? 0;
  });
}
String getQuestStatus() {
  if (streak >= 7) return " 7-Day Streak Complete!";
  if (streak >= 3) return " 3-Day Streak Achieved!";
  return "Start your fitness journey!";
}

  Future<void> addWorkout() async {
  showAddWorkoutDialog();
}

  Future<void> createAndTrackWorkout(String name) async {
    await DatabaseHelper.instance.createWorkout(name);

    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('streak') ?? 0;
    current++;

    await prefs.setInt('streak', current);

    await loadStreak();
    await loadWorkouts();
  }

  Future<void> showAddWorkoutDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start Workout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Workout name',
              hintText: 'Enter workout name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim().isEmpty
                    ? 'New Workout'
                    : controller.text.trim();
                Navigator.of(context).pop();
                createAndTrackWorkout(name);
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  Future<void> showEditNameDialog(Map<String, dynamic> workout) async {
    final controller = TextEditingController(text: workout['name']);
    final id = workout['id'] as int;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Workout Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Workout name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await DatabaseHelper.instance
                      .updateWorkout(id, {'name': newName});
                  await loadWorkouts();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  Future<void> deleteWorkout(int id) async {
    await DatabaseHelper.instance.deleteWorkout(id);
    loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Mobile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
              Text(
                "Current Streak: $streak days",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                getQuestStatus(),
                style: const TextStyle(fontSize: 16),
              ),
            ElevatedButton(
              onPressed: addWorkout,
              child: const Text('Start Workout'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/progress');
              },
              child: const Text("View Progress"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: const Text("Settings"),
            ),

            Expanded(
              child: workouts.isEmpty
                  ? const Center(child: Text("No workouts yet"))
                  : ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];

                        return ListTile(
                          title: Text(workout['name']),
                          subtitle: Text(workout['date']),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/workout',
                              arguments: workout['id'],
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => showEditNameDialog(workout),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteWorkout(workout['id']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}