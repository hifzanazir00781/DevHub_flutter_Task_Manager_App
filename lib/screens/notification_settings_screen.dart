import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _taskReminders = true;
  bool _dueDateReminders = true;
  bool _weeklySummary = false;
  bool _soundEnabled = true;
  bool _vibrateEnabled = true;
  String _reminderTime = '09:00 AM';
  int _reminderAdvance = 30; // minutes

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.notifications_active, color: theme.primaryColor),
                  title: const Text('Task Reminders'),
                  subtitle: const Text('Get notified about your tasks'),
                  value: _taskReminders,
                  onChanged: (value) => setState(() => _taskReminders = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.event_available, color: theme.primaryColor),
                  title: const Text('Due Date Reminders'),
                  subtitle: const Text('Remind me before task due date'),
                  value: _dueDateReminders,
                  onChanged: (value) => setState(() => _dueDateReminders = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.summarize, color: theme.primaryColor),
                  title: const Text('Weekly Summary'),
                  subtitle: const Text('Get weekly task summary every Monday'),
                  value: _weeklySummary,
                  onChanged: (value) => setState(() => _weeklySummary = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Reminder Time
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.access_time, color: theme.primaryColor),
                  title: const Text('Default Reminder Time'),
                  subtitle: Text(_reminderTime),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectTime(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.timer, color: theme.primaryColor),
                  title: const Text('Remind Me'),
                  subtitle: Text('$_reminderAdvance minutes before'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showAdvancePicker(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sound & Vibration
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.volume_up, color: theme.primaryColor),
                  title: const Text('Sound'),
                  value: _soundEnabled,
                  onChanged: (value) => setState(() => _soundEnabled = value),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.vibration, color: theme.primaryColor),
                  title: const Text('Vibrate'),
                  value: _vibrateEnabled,
                  onChanged: (value) => setState(() => _vibrateEnabled = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Do Not Disturb
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              secondary: Icon(Icons.do_not_disturb, color: theme.primaryColor),
              title: const Text('Do Not Disturb'),
              subtitle: const Text('Mute all notifications'),
              value: false,
              onChanged: (value) {
                // TODO: Implement DND
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked.format(context);
      });
    }
  }

  void _showAdvancePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remind Me'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('At time of event'),
              onTap: () {
                setState(() => _reminderAdvance = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('5 minutes before'),
              onTap: () {
                setState(() => _reminderAdvance = 5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('15 minutes before'),
              onTap: () {
                setState(() => _reminderAdvance = 15);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('30 minutes before'),
              onTap: () {
                setState(() => _reminderAdvance = 30);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('1 hour before'),
              onTap: () {
                setState(() => _reminderAdvance = 60);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}