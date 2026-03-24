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

  Future<void> addWorkout() async {
  await DatabaseHelper.instance.createWorkout("New Workout");

  final prefs = await SharedPreferences.getInstance();
  int current = prefs.getInt('streak') ?? 0;
  current++;

  await prefs.setInt('streak', current);

  loadStreak();
  loadWorkouts();
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteWorkout(workout['id']),
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