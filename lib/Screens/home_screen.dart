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
  final lastDateStr = prefs.getString('lastWorkoutDate');
  int current = prefs.getInt('streak') ?? 0;

  if (lastDateStr != null) {
    final lastDate = DateTime.parse(lastDateStr);
    final today = DateTime.now();
    final daysDiff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
        .inDays;
    if (daysDiff >= 2) {
      current = 0;
      await prefs.setInt('streak', 0);
    }
  }

  setState(() {
    streak = current;
  });
}
String getQuestStatus() {
  if (streak >= 21) return " 21-Day Streak Complete! 🔥🔥";
  if (streak >= 14) return " 14-Day Streak Complete! 🔥";
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
    final lastDateStr = prefs.getString('lastWorkoutDate');
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    int current = prefs.getInt('streak') ?? 0;

    if (lastDateStr == null) {
    
      current = 1;
    } else {
      final lastDate = DateTime.parse(lastDateStr);
      final lastOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final daysDiff = todayOnly.difference(lastOnly).inDays;

      if (daysDiff == 0) {
        
      } else if (daysDiff == 1) {
        current++;
      } else {
        current = 1;
      }
    }

    await prefs.setInt('streak', current);
    await prefs.setString('lastWorkoutDate', today.toIso8601String());

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
                Navigator.pushNamed(context, '/settings').then((_) {
                  if (mounted) {
                    loadWorkouts();
                    loadStreak();
                  }
                });
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

                        final dt = DateTime.tryParse(workout['date'] ?? '');
                        final formattedDate = dt != null
                            ? '${dt.month}/${dt.day}/${dt.year}'
                            : workout['date'];
                        return ListTile(
                          title: Text(workout['name']),
                          subtitle: Text(formattedDate),
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