import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static late SharedPreferences _prefs;
  static bool _isInitialized = false;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('StorageService must be initialized first. Call StorageService.init() in main.dart');
    }
  }

  // ==================== TASKS ====================
  
  Future<void> saveTasks(List<Task> tasks) async {
    _checkInitialized();
    List<String> tasksJson = tasks.map((task) => json.encode(task.toJson())).toList();
    await _prefs.setStringList('tasks', tasksJson);
  }

  List<Task> getTasks() {
    _checkInitialized();
    List<String>? tasksJson = _prefs.getStringList('tasks');
    if (tasksJson == null) return [];
    return tasksJson
        .map((jsonString) => Task.fromJson(json.decode(jsonString)))
        .toList()
      ..sort((a, b) {
        // Sort by: incomplete first, then by due date, then by priority
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        return a.priority.compareTo(b.priority);
      });
  }

  Future<void> addTask(Task task) async {
    final tasks = getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(Task updatedTask) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasks(tasks);
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(isCompleted: !tasks[index].isCompleted);
      await saveTasks(tasks);
    }
  }

  // ==================== USER ====================

  Future<void> saveUser(User user) async {
    _checkInitialized();
    await _prefs.setString('user', json.encode(user.toJson()));
  }

  User? getUser() {
    _checkInitialized();
    String? userJson = _prefs.getString('user');
    if (userJson == null) return null;
    return User.fromJson(json.decode(userJson));
  }

  Future<void> clearUser() async {
    await _prefs.remove('user');
  }

  // ==================== THEME ====================

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs.setBool('isDarkMode', isDarkMode);
  }

  bool? getThemeMode() {
    return _prefs.getBool('isDarkMode');
  }

  // ==================== CATEGORIES ====================

  Future<void> saveCategories(List<String> categories) async {
    await _prefs.setStringList('categories', categories);
  }

  List<String> getCategories() {
    return _prefs.getStringList('categories') ?? 
        ['Default', 'Personal', 'Work', 'Shopping', 'Health', 'Education'];
  }

  // ==================== CLEAR ALL ====================

  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}