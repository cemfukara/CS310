import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'settings_screen.dart';

/// Profile Screen - User profile display with placeholder fields
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder user data
  final Map<String, String> _userProfile = {
    'name': 'John',
    'surname': 'Doe',
    'email': 'john.doe@example.com',
    'workplace': 'Tech Company Inc.',
    'id': 'EMP-2024-001',
    'gender': 'Male',
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

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
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isSmallScreen
              ? AppStyles.paddingMedium
              : AppStyles.paddingLarge,
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
                  // Profile Image with Local Asset Fallback
                  Container(
                    width: isSmallScreen ? 120 : 160,
                    height: isSmallScreen ? 120 : 160,
                    decoration: BoxDecoration(
                      color: AppStyles.white,
                      borderRadius: AppStyles.borderRadiusXLargeAll,
                      border: Border.all(
                        color: AppStyles.white,
                        width: 3,
                      ),
                      boxShadow: AppStyles.shadowMedium,
                    ),
                    child: Image.asset(
                      'assets/images/profile_placeholder.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback UI when asset doesn't exist
                        return Container(
                          decoration: BoxDecoration(
                            color: AppStyles.nearWhite,
                            borderRadius: AppStyles.borderRadiusXLargeAll,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_outline,
                              size: 60,
                              color: AppStyles.mediumGray,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingLarge),

                  // User Name
                  Text(
                    '${_userProfile['name']} ${_userProfile['surname']}',
                    style: AppStyles.headingMedium.copyWith(
                      color: AppStyles.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppStyles.paddingSmall),

                  // User Role/Title
                  Text(
                    'Team Member',
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
            Text(
              'Personal Information',
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            // Profile Fields
            _buildProfileField(
              label: 'First Name',
              value: _userProfile['name'] ?? '',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            _buildProfileField(
              label: 'Last Name',
              value: _userProfile['surname'] ?? '',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            _buildProfileField(
              label: 'Email',
              value: _userProfile['email'] ?? '',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: AppStyles.paddingLarge),

            // Work/School Information Section
            Text(
              'Work Information',
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            _buildProfileField(
              label: 'Workplace/School',
              value: _userProfile['workplace'] ?? '',
              icon: Icons.work_outline,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            _buildProfileField(
              label: 'Employee ID',
              value: _userProfile['id'] ?? '',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            _buildProfileField(
              label: 'Gender',
              value: _userProfile['gender'] ?? '',
              icon: Icons.wc_outlined,
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
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      decoration: BoxDecoration(
        color: AppStyles.nearWhite,
        borderRadius: AppStyles.borderRadiusMediumAll,
        border: Border.all(
          color: AppStyles.lightGray,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingSmall),
            decoration: BoxDecoration(
              color: AppStyles.primaryPurple.withOpacity(0.1),
              borderRadius: AppStyles.borderRadiusSmallAll,
            ),
            child: Icon(
              icon,
              color: AppStyles.primaryPurple,
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
                  style: AppStyles.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppStyles.bodyLarge,
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
            side: const BorderSide(
              color: AppStyles.lightGray,
              width: 1.5,
            ),
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
                child: Text(
                  'Log Out?',
                  style: AppStyles.headingSmall,
                ),
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
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(
                'Log Out',
                style: AppStyles.labelLarge.copyWith(
                  color: AppStyles.errorRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
