import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Data/database_helper.dart';

// SettingsScreen lets the user reset data, switch themes, and view app info
class SettingsScreen extends StatelessWidget {
  // Function to call when the user taps the theme toggle
  final VoidCallback onThemeToggle;
  // Whether dark mode is currently on
  final bool isDarkMode;

  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  // Shows a confirmation popup, then wipes all data if the user confirms
  Future<void> _resetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'This will permanently delete all workouts, exercises, and progress. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Stop here if the user pressed Cancel
    if (confirmed != true) return;

    // Delete the database file
    await DatabaseHelper.resetDatabase();

    // Also clear the streak and last workout date from saved preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('streak');
    await prefs.remove('lastWorkoutDate');
    
    // Show a quick message to confirm the reset worked
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been reset.')),
      );
    }
  }

  // Opens Flutter's built-in "About" dialog with the app name and version
  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Fitness Mobile',
      applicationVersion: '1.0.0',
      applicationIcon: const Image(image: AssetImage('assets/Images/MainLogoIcon.png'), width: 50, height: 50 ),
      children: const [
        Text('A simple app to log workouts, track progress, and build streaks.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      // Each settings option is a ListTile in a scrollable list
      body: ListView(
        children: [
          // Option to delete all saved data
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset Data'),
            subtitle: const Text('Delete all workouts and progress'),
            onTap: () => _resetData(context),
          ),
          const Divider(),
          // Option to switch between dark and light mode
          ListTile(
            leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: const Text('Theme Toggle'),
            subtitle: Text(isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
            // Switch widget on the right side of the tile
            trailing: Switch(
              value: isDarkMode,
              onChanged: (_) => onThemeToggle(),
            ),
            onTap: onThemeToggle,
          ),
          const Divider(),
          // Option to see app version info
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            subtitle: const Text('Version info and description'),
            onTap: () => _showAbout(context),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
