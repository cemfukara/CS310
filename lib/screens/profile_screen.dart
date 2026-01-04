import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/gamification_provider.dart';
import 'settings_screen.dart';
import 'store_inventory_screen.dart';

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

    // Auth
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Gamification
    final gamification = Provider.of<GamificationProvider>(context);
    final equippedBadges = gamification.stats.equippedBadges;
    final equippedAvatarName = gamification.stats.equippedAvatar;

    // Resolve Avatar Icon
    IconData? avatarIcon;
    if (equippedAvatarName != null) {
      final avatarItem = StoreInventoryScreen.storeItems.firstWhere(
        (item) => item['name'] == equippedAvatarName,
        orElse: () => {},
      );
      if (avatarItem.isNotEmpty) {
        avatarIcon = avatarItem['icon'] as IconData;
      }
    }

    // --- Name Parsing ---
    String firstName = '';
    String lastName = '';

    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      List<String> parts = user.displayName!.split(' ');
      if (parts.length == 1) {
        firstName = parts.first;
      } else {
        lastName = parts.last;
        firstName = parts.sublist(0, parts.length - 1).join(' ');
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
            // ───────── PROFILE CARD ─────────
            Container(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              decoration: BoxDecoration(
                color: AppStyles.primaryPurple,
                borderRadius: AppStyles.borderRadiusLargeAll,
              ),
              child: Column(
                children: [
                  // Avatar
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
                      child: avatarIcon != null
                          ? Icon(
                              avatarIcon,
                              size: 80,
                              color: AppStyles.primaryPurple,
                            )
                          : Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: AppStyles.primaryPurple,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppStyles.paddingLarge),

                  // Name
                  Text(
                    user?.displayName ?? 'User',
                    style: AppStyles.headingMedium.copyWith(
                      color: AppStyles.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppStyles.paddingSmall),

                  // Email
                  Text(
                    email,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppStyles.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // ───────── BADGES SECTION ─────────
                  if (equippedBadges.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Equipped Badges",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: equippedBadges.map((badge) {
                              return Chip(
                                label: Text(badge),
                                avatar: const Icon(
                                  Icons.military_tech,
                                  size: 18,
                                  color: AppStyles.primaryPurple,
                                ),
                                backgroundColor: Colors.white,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppStyles.paddingXLarge),

            // ───────── PERSONAL INFO ─────────
            Text('Personal Information', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),

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

            // ───────── ACTION BUTTONS ─────────
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const StoreInventoryScreen(initialShowStore: false),
                  ),
                );
              },
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('My Inventory'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppStyles.paddingMedium,
                ),
                backgroundColor: AppStyles.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: AppStyles.paddingMedium),

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
              onPressed: () => _showLogoutDialog(context),
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

  /// Build profile field UI
  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppStyles.borderRadiusMediumAll,
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppStyles.paddingSmall),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: AppStyles.borderRadiusSmallAll,
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: AppStyles.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not set',
                  style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Logout dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
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
                ),
              ),
              const SizedBox(width: AppStyles.paddingMedium),
              const Expanded(
                child: Text('Log Out?', style: AppStyles.headingSmall),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: AppStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppStyles.labelLarge.copyWith(
                  color: AppStyles.primaryPurple,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
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
