import 'package:flutter/material.dart';
import '../Data/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

// HomeScreen is the main page the user sees after opening the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of all saved workouts to show on screen
  List<Map<String, dynamic>> workouts = [];
  // How many days in a row the user has worked out
  int streak = 0;

  @override
  void initState() {
    super.initState();
    // Load workouts and streak as soon as the screen opens
    loadWorkouts();
    loadStreak();
  }

  // Fetches all workouts from the database and updates the screen
  Future<void> loadWorkouts() async {
    final data = await DatabaseHelper.instance.getWorkouts();
    setState(() {
      workouts = data;
    });
  }

  // Checks the streak and resets it if the user missed more than a day
  Future<void> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('lastWorkoutDate');
    int current = prefs.getInt('streak') ?? 0;

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final today = DateTime.now();
      // Calculate how many full days have passed since the last workout
      final daysDiff = DateTime(today.year, today.month, today.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;
      // If 2 or more days passed with no workout, reset the streak
      if (daysDiff >= 2) {
        current = 0;
        await prefs.setInt('streak', 0);
      }
    }

    setState(() {
      streak = current;
    });
  }

  // Returns a motivational message based on how long the streak is
  String getQuestStatus() {
    if (streak >= 21) return "21-Day Streak Complete! ????";
    if (streak >= 14) return "14-Day Streak Complete! ??";
    if (streak >= 7) return "7-Day Streak Complete!";
    if (streak >= 3) return "3-Day Streak Achieved!";
    return "Start your fitness journey!";
  }

  // Opens the dialog to create a new workout
  Future<void> addWorkout() async {
    showAddWorkoutDialog();
  }

  // Saves the new workout and updates the streak counter
  Future<void> createAndTrackWorkout(String name) async {
    await DatabaseHelper.instance.createWorkout(name);

    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('lastWorkoutDate');
    final today = DateTime.now();
    // Strip the time so we only compare dates (not hours/minutes)
    final todayOnly = DateTime(today.year, today.month, today.day);
    int current = prefs.getInt('streak') ?? 0;

    if (lastDateStr == null) {
      // First workout ever — start streak at 1
      current = 1;
    } else {
      final lastDate = DateTime.parse(lastDateStr);
      final lastOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final daysDiff = todayOnly.difference(lastOnly).inDays;

      if (daysDiff == 0) {
        // Already worked out today — streak stays the same
      } else if (daysDiff == 1) {
        // Worked out the very next day — keep the streak going
        current++;
      } else {
        // Missed a day — restart the streak
        current = 1;
      }
    }

    // Save the updated streak and today's date
    await prefs.setInt('streak', current);
    await prefs.setString('lastWorkoutDate', today.toIso8601String());

    await loadStreak();
    await loadWorkouts();
  }

  // Shows a popup where the user types the name for a new workout
  Future<void> showAddWorkoutDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Workout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Workout name',
              hintText: 'e.g. Chest Day, Morning Run',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Use "New Workout" as the name if the user left it blank
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

  // Shows a popup that lets the user rename an existing workout
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
            FilledButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  // Save the new name to the database
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

  // Removes a workout from the database then refreshes the list
  Future<void> deleteWorkout(int id) async {
    await DatabaseHelper.instance.deleteWorkout(id);
    loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Mobile'),
        actions: [
          // Button to go to the Progress screen
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.pushNamed(context, '/progress'),
          ),
          // Button to go to the Settings screen
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, '/settings').then((_) {
              // Refresh data when coming back from settings
              if (mounted) {
                loadWorkouts();
                loadStreak();
              }
            }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Shows how many days in a row the user has worked out
            Text(
              'Current Streak: $streak days',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Shows the milestone message (e.g. "7-Day Streak!")
            Text(getQuestStatus()),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addWorkout,
                child: const Text('Create Workout'),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Workouts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            // Shows all saved workouts in a scrollable list
            Expanded(
              child: workouts.isEmpty
                  ? const Center(child: Text('No workouts yet'))
                  : ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
                        // Format the date as MM/DD/YYYY for display
                        final dt = DateTime.tryParse(workout['date'] ?? '');
                        final formattedDate = dt != null
                            ? '${dt.month}/${dt.day}/${dt.year}'
                            : workout['date'];
                        return ListTile(
                          title: Text(workout['name']),
                          subtitle: Text(formattedDate),
                          // Tap the workout to open its exercise log
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/workout',
                            arguments: workout['id'],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pencil icon to rename the workout
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => showEditNameDialog(workout),
                              ),
                              // Trash icon to delete the workout
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

