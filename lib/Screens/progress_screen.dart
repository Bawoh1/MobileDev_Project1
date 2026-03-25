import 'package:flutter/material.dart';
import '../Data/database_helper.dart';

// ProgressScreen shows workout stats and personal records
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Maps each exercise name to its heaviest weight ever lifted (personal record)
  Map<String, double> prMap = {};
  // Overall counts and averages shown as stat cards
  int totalWorkouts = 0;
  int totalExercises = 0;
  double maxWeight = 0;
  double avgSets = 0;
  double avgReps = 0;

  @override
  void initState() {
    super.initState();
    // Load all stats when this screen opens
    loadStats();
  }

  // Reads all workouts and exercises from the database and calculates stats
  Future<void> loadStats() async {
  final db = await DatabaseHelper.instance.database;

  final workouts = await db.query('workouts');
  final exercises = await db.query('exercises');

  int setsSum = 0;
  int repsSum = 0;
  double maxW = 0;

  // Start fresh so old data doesn't stick around
  prMap.clear(); 

  // Loop through every exercise to gather totals
  for (var ex in exercises) {
    setsSum += (ex['sets'] as int?) ?? 0;
    repsSum += (ex['reps'] as int?) ?? 0;

    double w = (ex['weight'] as num?)?.toDouble() ?? 0;
    String name = (ex['name'] as String?) ?? '';

    // Track the single heaviest weight across all exercises
    if (w > maxW) maxW = w;

    // Update the personal record for this exercise if this weight is heavier
    if (w > 0 && (!prMap.containsKey(name) || w > prMap[name]!)) {
      prMap[name] = w;
    }
  }

  setState(() {
    totalWorkouts = workouts.length;
    totalExercises = exercises.length;
    maxWeight = maxW;
    // Average = total divided by count (avoid dividing by zero)
    avgSets = exercises.isEmpty ? 0 : setsSum / exercises.length;
    avgReps = exercises.isEmpty ? 0 : repsSum / exercises.length;
  });
}

  // Builds a small card that shows a label and a big bold number
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

  // Clears the personal record for one exercise by setting its weight to 0
  Future<void> deletePersonalRecord(String name) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'exercises',
      {'weight': 0},
      where: 'name = ?',
      whereArgs: [name],
    );
    
    // Remove from the on-screen map right away so the list updates instantly
    setState(() {
      prMap.remove(name);
    });
    await loadStats();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Progress")),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left column — stat cards (totals and averages)
          Expanded(
            child: SingleChildScrollView(
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
          ),

          const SizedBox(width: 12),

          // Right column — personal records list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Personal Records",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Show each exercise's best weight, or a "no records" message
                Expanded(
                  child: prMap.isEmpty
                      ? const Center(child: Text("No records yet"))
                      : ListView(
                          children: prMap.entries.map((entry) {
                            return Card(
                              child: ListTile(
                                title: Text(entry.key),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${entry.value} lbs"),
                                    // Red trash icon to delete this personal record
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete record',
                                      onPressed: () async {
                                        // Ask the user to confirm before deleting
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text('Delete record'),
                                            content: Text('Delete personal record for "${entry.key}"? This cannot be undone.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await deletePersonalRecord(entry.key);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Deleted record for ${entry.key}')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
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
}