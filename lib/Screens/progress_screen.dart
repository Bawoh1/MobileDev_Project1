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
      // TODO: Add stats loading logic here
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Progress'),
        ),
        body: Center(
          child: Text('Total Workouts: $totalWorkouts'),
        ),
      );
    }
  }