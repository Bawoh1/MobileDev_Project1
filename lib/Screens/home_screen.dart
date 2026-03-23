import 'package:flutter/material.dart';
import '../Data/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> workouts = [];

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    final data = await DatabaseHelper.instance.getWorkouts();
    setState(() {
      workouts = data;
    });
  }

  Future<void> addWorkout() async {
    await DatabaseHelper.instance.createWorkout("New Workout");
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
            ElevatedButton(
              onPressed: addWorkout,
              child: const Text('Start Workout'),
            ),

            const SizedBox(height: 20),

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