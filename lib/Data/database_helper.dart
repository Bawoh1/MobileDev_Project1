// Import required packages
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// DatabaseHelper class - Singleton pattern
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // Private constructor
  DatabaseHelper._init();
  
  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('myapp.db');
    return _database!;
  }
  
  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }
  
  // Create database tables
  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE workouts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      date TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE exercises (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      workout_id INTEGER,
      name TEXT NOT NULL,
      sets INTEGER,
      reps INTEGER,
      weight REAL,
      FOREIGN KEY (workout_id) REFERENCES workouts (id)
    )
  ''');
}
  
// CREATE workout
Future<int> createWorkout(String name) async {
  final db = await database;

  return await db.insert('workouts', {
    'name': name,
    'date': DateTime.now().toIso8601String(),
  });
}

// READ workouts
Future<List<Map<String, dynamic>>> getWorkouts() async {
  final db = await database;
  return await db.query('workouts', orderBy: 'date DESC');
}

// DELETE workout
Future<int> deleteWorkout(int id) async {
  final db = await database;
  return await db.delete(
    'workouts',
    where: 'id = ?',
    whereArgs: [id],
  );
}
  
  // Close database connection
  Future close() async {
    final db = await database;
    db.close();
  }
}
