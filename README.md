TaskFlow - Your Personal Task Manager

TaskFlow is a beautiful and intuitive Flutter task management application that helps you organize your daily tasks efficiently. With a clean UI and local storage, it's perfect for personal productivity.

✨ Features
✅ Create, edit, and delete tasks

🔍 Search and filter tasks

📅 Set due dates and times

🏷️ Categorize tasks (Personal, Work, Shopping, etc.)

⚡ Priority levels (High, Medium, Low)

📊 Task statistics dashboard

👤 User profile management

🌓 Dark/Light theme support

💾 Local storage with SharedPreferences

📸 Screenshots
Authentication Screens
Splash Screen	Welcome Screen	Login Screen
https://screenshots/splash_screen.png	https://screenshots/welcome_screen.png	https://screenshots/login_screen.png
Login Validation	Sign Up Screen	Sign Up Form
https://screenshots/login_validation.png	https://screenshots/signup_screen.png	https://screenshots/signup_form.png
Forgot Password
https://screenshots/forgot_password.png
Task Management Screens
Home Dashboard	Task Details	Add New Task
https://screenshots/home_dashboard.png	https://screenshots/task_details.png	https://screenshots/add_task.png
Date Selection	Time Selection	Tasks List
https://screenshots/date_picker.png	https://screenshots/time_picker.png	https://screenshots/tasks_list.png
Edit Task	Task Stats	Empty State
https://screenshots/edit_task.png	https://screenshots/task_stats.png	https://screenshots/empty_state.png
Profile & Settings Screens
Profile Screen	Edit Profile	Settings
https://screenshots/profile_screen.png	https://screenshots/edit_profile.png	https://screenshots/settings.png
Notification Settings	Data Privacy	Account Actions
https://screenshots/notification_settings.png	https://screenshots/data_privacy.png	https://screenshots/account_actions.png
🚀 Getting Started
Prerequisites
Flutter SDK (>=3.0.0)

Dart SDK (>=3.0.0)

Android Studio / VS Code

Installation
Clone the repository

bash
git clone https://github.com/yourusername/task_flow_app.git
Navigate to project directory

bash
cd task_flow_app
Install dependencies

bash
flutter pub get
Run the app

bash
# For Chrome (Web)
flutter run -d chrome --web-renderer html

# For Windows
flutter run -d windows

# For Android
flutter run -d android
📁 Project Structure
text
lib/
├── models/           # Data models (Task, User)
│   ├── task.dart
│   └── user.dart
│
├── screens/          # All UI screens
│   ├── splash_screen.dart
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart
│   ├── add_task_screen.dart
│   ├── edit_task_screen.dart
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   └── notification_settings_screen.dart
│
├── services/         # Storage service
│   └── storage_service.dart
│
├── utils/            # Constants and helpers
│   └── constants.dart
│
├── widgets/          # Reusable widgets
│   ├── custom_textfield.dart
│   ├── task_tile.dart
│   └── social_login_button.dart
│
└── main.dart         # Entry point
🛠️ Built With
Flutter - UI framework

SharedPreferences - Local storage

Google Fonts - Typography

intl - Date formatting

provider - State management

url_launcher - Opening links

📦 Dependencies
yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  google_fonts: ^6.1.0
  provider: ^6.1.1
  intl: ^0.19.0
  url_launcher: ^6.2.4
🎯 Key Features Explained
Task Management
Create tasks with title, description, due date, and priority

Edit existing tasks

Mark tasks as complete/incomplete

Delete tasks with confirmation

Search tasks by title or description

Filter tasks by: All, Today, Important, Completed

Data Persistence
All tasks saved locally using SharedPreferences

User profile information stored securely

Theme preferences remembered

Categories management

User Experience
Smooth animations and transitions

Intuitive navigation

Form validations

Snackbar notifications

Pull to refresh

Empty state handling

🔜 Future Enhancements
Cloud sync with Firebase

Task reminders with notifications

Subtasks support

Task attachments

Collaborative tasks

Statistics and charts

Export/Import tasks

Home screen widget


👨‍💻 Developer
Hifza Nazir

GitHub: @hifzanazir00781

Email: hifzanazir456@gmail.com

