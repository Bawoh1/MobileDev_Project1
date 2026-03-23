import 'package:flutter/material.dart';
import '../Data/database_helper.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  int? workoutId;
  List<Map<String, dynamic>> exercises = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    workoutId = ModalRoute.of(context)!.settings.arguments as int?;
    loadExercises();
  }

  Future<void> loadExercises() async {
    if (workoutId == null) return;

    final db = await DatabaseHelper.instance.database;
    final data = await db.query(
      'exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );

    setState(() {
      exercises = data;
    });
  }

  Future<void> addExercise() async {
    if (nameController.text.isEmpty ||
        setsController.text.isEmpty ||
        repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;

    await db.insert('exercises', {
      'workout_id': workoutId,
      'name': nameController.text,
      'sets': int.parse(setsController.text),
      'reps': int.parse(repsController.text),
      'weight': double.tryParse(weightController.text) ?? 0,
    });

    nameController.clear();
    setsController.clear();
    repsController.clear();
    weightController.clear();

    loadExercises();
  }

  Future<void> deleteExercise(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );

    loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout Log")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Exercise Name"),
            ),
            TextField(
              controller: setsController,
              decoration: const InputDecoration(labelText: "Sets"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: "Reps"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: "Weight"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addExercise,
              child: const Text("Add Exercise"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: exercises.isEmpty
                  ? const Center(child: Text("No exercises yet"))
                  : ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final ex = exercises[index];

                        return ListTile(
                          title: Text(ex['name']),
                          subtitle: Text(
                              "${ex['sets']} sets x ${ex['reps']} reps | ${ex['weight']} lbs"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteExercise(ex['id']),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}