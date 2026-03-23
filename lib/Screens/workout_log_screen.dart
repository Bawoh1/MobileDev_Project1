import 'package:flutter/material.dart';

class WorkoutLogScreen extends StatelessWidget {
  const WorkoutLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('+ Add Exercise'),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: const [
                  ListTile(title: Text('Bench Press')),
                  ListTile(title: Text('Squat')),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {},
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}