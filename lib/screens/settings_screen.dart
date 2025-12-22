import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:promise/providers/theme_provider.dart';

/// Settings Screen - App configuration and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailDigest = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isSmallScreen ? AppStyles.paddingMedium : AppStyles.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Section
            Text('Account', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),
            _buildSettingsTile(
              title: 'Profile Information',
              subtitle: 'Update your profile details',
              icon: Icons.person,
              onTap: () => _showProfileDialog(),
            ),
            _buildSettingsTile(
              title: 'Change Password',
              subtitle: 'Update your password',
              icon: Icons.lock,
              onTap: () => _showPasswordDialog(),
            ),
            _buildSettingsTile(
              title: 'Email Address',
              subtitle: 'user@example.com',
              icon: Icons.email,
              onTap: () => _showEmailDialog(),
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Notifications Section
            Text('Notifications', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),
            _buildSwitchTile(
              title: 'Enable Notifications',
              subtitle: 'Receive promise reminders',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
              icon: Icons.notifications,
            ),
            _buildSwitchTile(
              title: 'Weekly Email Digest',
              subtitle: 'Receive promise summary every week',
              value: _emailDigest,
              onChanged: (value) {
                setState(() => _emailDigest = value);
              },
              icon: Icons.mail,
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Preferences Section
            Text('Preferences', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Use dark theme',
              value: themeProvider.isDark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              icon: Icons.dark_mode,
            ),
            _buildDropdownTile(
              title: 'Language',
              value: _selectedLanguage,
              items: ['English', 'Spanish', 'French', 'German', 'Chinese'],
              onChanged: (value) {
                setState(() => _selectedLanguage = value);
              },
              icon: Icons.language,
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Privacy & Security
            Text('Privacy & Security', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),
            _buildSettingsTile(
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy',
              icon: Icons.description,
              onTap: () => _showInfoDialog('Privacy Policy'),
            ),
            _buildSettingsTile(
              title: 'Terms of Service',
              subtitle: 'View terms and conditions',
              icon: Icons.document_scanner,
              onTap: () => _showInfoDialog('Terms of Service'),
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // App Info
            Text('App Information', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),
            _buildInfoTile(
              title: 'App Version',
              value: '1.0.0',
              icon: Icons.info,
            ),
            _buildInfoTile(
              title: 'Build Number',
              value: '2025.11.24',
              icon: Icons.build,
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Danger Zone
            Text('Danger Zone', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),
            ElevatedButton.icon(
              onPressed: _showClearDataDialog,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear All Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.dangerRed,
                foregroundColor: AppStyles.white,
              ),
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryPurple,
                foregroundColor: AppStyles.white,
              ),
            ),
            const SizedBox(height: AppStyles.paddingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppStyles.primaryPurple),
        title: Text(title, style: AppStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppStyles.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppStyles.primaryPurple),
        title: Text(title, style: AppStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppStyles.bodySmall),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppStyles.primaryPurple,
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppStyles.primaryPurple),
        title: Text(title, style: AppStyles.bodyLarge),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppStyles.primaryPurple),
        title: Text(title, style: AppStyles.bodyLarge),
        trailing: Text(value, style: AppStyles.bodySmall),
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
              ),
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            TextField(
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: TextField(
          decoration: InputDecoration(
            labelText: 'New Email Address',
            border: OutlineInputBorder(
              borderRadius: AppStyles.borderRadiusSmallAll,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification email sent')),
              );
              Navigator.pop(context);
            },
            child: const Text('Send Verification'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\n'
            'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This action cannot be undone. All your promises and data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('All data cleared')));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.dangerRed,
              foregroundColor: AppStyles.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
