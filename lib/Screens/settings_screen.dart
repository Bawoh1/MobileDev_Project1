import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Data/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const SettingsScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

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

    if (confirmed != true) return;

    final db = await DatabaseHelper.instance.database;
    await db.delete('exercises');
    await db.delete('workouts');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('streak');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been reset.')),
      );
    }
  }

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
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset Data'),
            subtitle: const Text('Delete all workouts and progress'),
            onTap: () => _resetData(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: const Text('Theme Toggle'),
            subtitle: Text(isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (_) => onThemeToggle(),
            ),
            onTap: onThemeToggle,
          ),
          const Divider(),
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
