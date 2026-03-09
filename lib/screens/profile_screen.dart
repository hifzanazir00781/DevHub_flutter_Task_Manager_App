import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _language = 'English';
  String _theme = 'System Default';

  final List<String> _languages = ['English', 'Urdu', 'Spanish', 'French', 'Arabic'];
  final List<String> _themes = ['Light', 'Dark', 'System Default'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    final user = StorageService().getUser();
    setState(() {
      _user = user;
    });
  }

  Future<void> _loadSettings() async {
    final themeMode = StorageService().getThemeMode();
    setState(() {
      _isDarkMode = themeMode ?? false;
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService().clearUser();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be lost forever.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService().clearAllData();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              ).then((_) => _loadUserData());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        _user?.name.isNotEmpty == true 
                            ? _user!.name[0].toUpperCase() 
                            : 'U',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.name ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?.email ?? 'user@email.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Member since ${_user != null ? _formatDate(_user!.createdAt) : 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Settings
            _buildSection(
              title: 'Account Settings',
              children: [
                _buildListTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    ).then((_) => _loadUserData());
                  },
                ),
                _buildListTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    // TODO: Change Password Screen
                  },
                ),
                _buildListTile(
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  subtitle: _user?.email ?? 'user@email.com',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Preferences
            _buildSection(
              title: 'Preferences',
              children: [
                // Theme Selection
                _buildListTile(
                  icon: Icons.brightness_6_outlined,
                  title: 'Theme',
                  trailing: DropdownButton<String>(
                    value: _theme,
                    items: _themes.map((String theme) {
                      return DropdownMenuItem(
                        value: theme,
                        child: Text(theme),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _theme = value!);
                      // Apply theme change
                      if (value == 'Dark') {
                        // TODO: Set dark mode
                      } else if (value == 'Light') {
                        // TODO: Set light mode
                      } else {
                        // TODO: Set system default
                      }
                    },
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),

                // Language Selection
                _buildListTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  trailing: DropdownButton<String>(
                    value: _language,
                    items: _languages.map((String lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _language = value!);
                      // TODO: Change app language
                    },
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notifications
            _buildSection(
              title: 'Notifications',
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Push Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                if (_notificationsEnabled) ...[
                  SwitchListTile(
                    secondary: Icon(
                      Icons.notifications_active_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Task Reminders'),
                    subtitle: const Text('Get notified about upcoming tasks'),
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() => _pushNotifications = value);
                    },
                  ),
                  SwitchListTile(
                    secondary: Icon(
                      Icons.email_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive weekly summary via email'),
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() => _emailNotifications = value);
                    },
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Data & Privacy
            _buildSection(
              title: 'Data & Privacy',
              children: [
                _buildListTile(
                  icon: Icons.backup_outlined,
                  title: 'Backup Data',
                  subtitle: 'Last backup: Never',
                  onTap: () {
                    // TODO: Backup data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup started...')),
                    );
                  },
                ),
                _buildListTile(
                  icon: Icons.restore_outlined,
                  title: 'Restore Data',
                  onTap: () {
                    // TODO: Restore data
                  },
                ),
                _buildListTile(
                  icon: Icons.delete_outline,
                  title: 'Clear All Tasks',
                  onTap: () => _showClearTasksDialog(),
                  titleColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Support & About
            _buildSection(
              title: 'Support & About',
              children: [
                _buildListTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () => _launchURL('https://help.taskflow.com'),
                ),
                _buildListTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  onTap: () {
                    // TODO: Feedback screen
                  },
                ),
                _buildListTile(
                  icon: Icons.star_outline,
                  title: 'Rate Us',
                  onTap: () => _launchURL('https://play.google.com/store/apps/details?id=com.taskflow.app'),
                ),
                _buildListTile(
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  onTap: () {
                    // TODO: Share app
                  },
                ),
                _buildListTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAboutDialog(),
                ),
                _buildListTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _launchURL('https://taskflow.com/privacy'),
                ),
                _buildListTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _launchURL('https://taskflow.com/terms'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Account Actions
            _buildSection(
              title: 'Account Actions',
              children: [
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: _logout,
                  titleColor: Colors.orange,
                ),
                _buildListTile(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  onTap: _deleteAccount,
                  titleColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'TaskFlow v1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 TaskFlow. All rights reserved.',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: titleColor != null ? FontWeight.w500 : null,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _showClearTasksDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text('Are you sure you want to delete all tasks? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService().saveTasks([]);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All tasks cleared')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About TaskFlow'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.task_alt, size: 60, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'TaskFlow v1.0.0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your personal task manager to stay organized and productive.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Developed with ❤️ using Flutter',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}