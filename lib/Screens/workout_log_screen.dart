import 'package:flutter/material.dart';
import '../Data/database_helper.dart';

// WorkoutLogScreen shows the exercises inside a single workout
class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  // The id of the workout we're viewing (passed in from the home screen)
  int? workoutId;
  // When editing an existing exercise, this holds its id
  int? editingId;
  // List of all exercises for this workout
  List<Map<String, dynamic>> exercises = [];

  // Text boxes at the top of the screen for entering exercise details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Grab the workout id that was passed when navigating to this screen
    workoutId = ModalRoute.of(context)!.settings.arguments as int?;
    loadExercises();
  }

  // Fetches all exercises for the current workout from the database
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

  // Shows a brief error message at the bottom of the screen
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Validates the form fields, then saves or updates an exercise
  Future<void> addExercise() async {
    final name = nameController.text.trim();
    final sets = int.tryParse(setsController.text);
    final reps = int.tryParse(repsController.text);
    final weightInput = weightController.text.trim();
    // If weight is left blank, treat it as 0 (bodyweight exercise)
    final weight = weightInput.isEmpty ? 0 : double.tryParse(weightInput);

    // Make sure the user filled in a name
    if (name.isEmpty) {
      showError("Exercise name is required");
      return;
    }

    // Make sure sets and reps are actual numbers
    if (sets == null || reps == null) {
      showError("Sets and reps must be valid numbers");
      return;
    }

    // Sets and reps must be at least 1
    if (sets <= 0 || reps <= 0) {
      showError("Sets and reps must be greater than 0");
      return;
    }

    // Weight must be a valid number (or empty)
    if (weight == null) {
      showError("Weight must be a valid number");
      return;
    }

    final db = await DatabaseHelper.instance.database;

    if (editingId != null) {
      // Update an existing exercise row
      await db.update(
        'exercises',
        {
          'workout_id': workoutId,
          'name': name,
          'sets': sets,
          'reps': reps,
          'weight': weight,
        },
        where: 'id = ?',
        whereArgs: [editingId],
      );
      // Clear editingId so the next save creates a new exercise instead
      editingId = null;
    } else {
      // Insert a brand new exercise row
      await db.insert('exercises', {
        'workout_id': workoutId,
        'name': name,
        'sets': sets,
        'reps': reps,
        'weight': weight,
      });
    }

    // Clear all the text boxes after saving
    nameController.clear();
    setsController.clear();
    repsController.clear();
    weightController.clear();

    loadExercises();
  }

  // Removes an exercise from the database then refreshes the list
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
            // Input fields for the exercise details
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

            // Pressing this button saves the exercise (or updates it if editing)
            ElevatedButton(
              onPressed: addExercise,
              child: const Text("Add Exercise"),
            ),

            const SizedBox(height: 20),

            // Scrollable list of all exercises in this workout
            Expanded(
              child: exercises.isEmpty
                  ? const Center(child: Text("No exercises yet"))
                  : ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final ex = exercises[index];

                        return ListTile(
                          title: Text(ex['name']),
                          // Shows sets, reps, and weight in one line
                          subtitle: Text(
                            "${ex['sets']} sets x ${ex['reps']} reps | ${ex['weight']} lbs"
                          ),
                          // Tap an exercise to load it into the form for editing
                          onTap: () {
                            nameController.text = ex['name'];
                            setsController.text = ex['sets'].toString();
                            repsController.text = ex['reps'].toString();
                            weightController.text = ex['weight'].toString();
                            // Remember which exercise we're editing
                            editingId = ex['id'];
                          },
                          // Trash icon to delete this exercise
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