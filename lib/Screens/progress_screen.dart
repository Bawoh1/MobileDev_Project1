import 'package:flutter/material.dart';
import '../Data/database_helper.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int totalWorkouts = 0;
  int totalExercises = 0;
  double maxWeight = 0;
  double avgSets = 0;
  double avgReps = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final db = await DatabaseHelper.instance.database;

    final workouts = await db.query('workouts');
    
    final exercises = await db.query('exercises');

    int setsSum = 0;
    int repsSum = 0;

    double maxW = 0;

    for (var ex in exercises) {
      setsSum += (ex['sets'] as int?) ?? 0;
      repsSum += (ex['reps'] as int?) ?? 0;

      double w = (ex['weight'] as num?)?.toDouble() ?? 0;
      if (w > maxW) maxW = w;
    }

    setState(() {
      totalWorkouts = workouts.length;
      totalExercises = exercises.length;
      maxWeight = maxW;

      avgSets = exercises.isEmpty ? 0 : setsSum / exercises.length;
      avgReps = exercises.isEmpty ? 0 : repsSum / exercises.length;
    });
  }

  Widget statCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Progress")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            statCard("Total Workouts", "$totalWorkouts"),
            statCard("Total Exercises", "$totalExercises"),
            statCard("Max Weight", "$maxWeight lbs"),
            statCard("Avg Sets", avgSets.toStringAsFixed(1)),
            statCard("Avg Reps", avgReps.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }
}