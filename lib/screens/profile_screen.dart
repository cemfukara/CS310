import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/auth_provider.dart';
import 'settings_screen.dart';

/// Profile Screen - Displays real user data from Firebase Auth
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // 1. Get the real user from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // 2. Parse Name (Updated Logic)
    // Splits "Isa Gorkem Akdogan" correctly into First: "Isa Gorkem", Last: "Akdogan"
    String firstName = '';
    String lastName = '';

    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      List<String> nameParts = user.displayName!.split(' ');
      if (nameParts.isNotEmpty) {
        if (nameParts.length == 1) {
          // If only one name exists (e.g. "Isa"), it's the first name
          firstName = nameParts.first;
        } else {
          // Take the LAST part as the Last Name
          lastName = nameParts.last;
          // Join all previous parts as the First Name
          firstName = nameParts.sublist(0, nameParts.length - 1).join(' ');
        }
      }
    }

    final email = user?.email ?? 'No email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isSmallScreen ? AppStyles.paddingMedium : AppStyles.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Picture Card
            Container(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              decoration: BoxDecoration(
                color: AppStyles.primaryPurple,
                borderRadius: AppStyles.borderRadiusLargeAll,
              ),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: isSmallScreen ? 120 : 160,
                    height: isSmallScreen ? 120 : 160,
                    decoration: BoxDecoration(
                      color: AppStyles.white,
                      borderRadius: AppStyles.borderRadiusXLargeAll,
                      border: Border.all(color: AppStyles.white, width: 3),
                      boxShadow: AppStyles.shadowMedium,
                    ),
                    child: Center(
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingLarge),

                  // User Name
                  Text(
                    user?.displayName ?? 'User',
                    style: AppStyles.headingMedium.copyWith(
                      color: AppStyles.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppStyles.paddingSmall),

                  // User Email
                  Text(
                    email,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppStyles.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Profile Information Section
            Text('Personal Information', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),

            // Profile Fields (Real Data)
            _buildProfileField(
              label: 'First Name',
              value: firstName,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            _buildProfileField(
              label: 'Last Name',
              value: lastName,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            _buildProfileField(
              label: 'Email',
              value: email,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Settings'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.paddingMedium,
                ),
              ),
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual profile field
  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppStyles.borderRadiusMediumAll,
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingSmall),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: AppStyles.borderRadiusSmallAll,
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: AppStyles.iconSizeMedium,
            ),
          ),
          const SizedBox(width: AppStyles.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not set',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppStyles.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppStyles.borderRadiusMediumAll,
            side: const BorderSide(color: AppStyles.lightGray, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppStyles.warningOrange.withOpacity(0.1),
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: AppStyles.warningOrange,
                  size: AppStyles.iconSizeMedium,
                ),
              ),
              const SizedBox(width: AppStyles.paddingMedium),
              const Expanded(
                child: Text('Log Out?', style: AppStyles.headingSmall),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to log out? You\'ll need to log in again to access your promises.',
            style: AppStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppStyles.labelLarge.copyWith(
                  color: AppStyles.primaryPurple,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Call the Logout method in Provider
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pop();
                // AuthWrapper in main.dart will handle the redirect to Login
              },
              child: Text(
                'Log Out',
                style: AppStyles.labelLarge.copyWith(color: AppStyles.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }
}