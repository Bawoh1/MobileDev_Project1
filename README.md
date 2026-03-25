# Fitness Mobile

Fitness Mobile is an application built using Flutter that helps users track workouts, stay consistent, and visualize their fitness progress over time.

## Features

### Workout Tracking
- Create and delete workouts
- View all current workouts

### Exercise Logging
- Add specific exercises to workout plans
- Input sets, reps, and weight
- Edit and delete exercises

### Progress tracking
- Total workouts and exercises tracked
- Average sets and reps
- Maximum weight lifted
- Personal records per exercise

##  Data Persistence

### SQLite (sqflite)
Used for structured data:
- workouts table
- exercises table (linked with workout_id)

Supports full CRUD:
- Create, Read, Update, Delete workouts and exercises

### SharedPreferences
Used for lightweight data:
- Simple settings
- Streak tracking

---

## Validation & Error Handling

- Prevents empty input fields
- Prevents invalid numbers (uses tryParse)
- Displays error messages using Snackbars instead of crashing

## Summary

This app demonstrates:
- Full CRUD operations with SQLite
- Local data persistence
- Input validation and error handling
- Simplistic UI with multiple screens