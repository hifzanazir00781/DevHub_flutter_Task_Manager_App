import 'package:intl/intl.dart';

class Constants {
  // Date Formatters
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference < 7) {
      return 'In $difference days';
    } else {
      return formatDate(date);
    }
  }

  // Priority Colors
  static const Map<int, String> priorityNames = {
    1: 'High',
    2: 'Medium',
    3: 'Low',
  };

  // App Constants
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';

  // Shared Preferences Keys
  static const String prefTasks = 'tasks';
  static const String prefUser = 'user';
  static const String prefTheme = 'theme';
  static const String prefCategories = 'categories';
  static const String prefOnboardingComplete = 'onboarding_complete';

  // Default Categories
  static const List<String> defaultCategories = [
    'Default',
    'Personal',
    'Work',
    'Shopping',
    'Health',
    'Education',
  ];
}