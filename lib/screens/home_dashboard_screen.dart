import 'package:flutter/material.dart';
import '../models/promise_model.dart';
import '../utils/app_styles.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';
import 'promises_screen.dart';
import 'friends_screen.dart';
import 'settings_screen.dart';
import 'store_screen.dart';
import 'achievements_screen.dart';

/// Home Dashboard Screen - Main page with BottomNavigationBar
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;

  // List of today's promises - dynamically managed
  late List<PromiseModel> _todayPromises;

  @override
  void initState() {
    super.initState();
    _todayPromises = PromiseModel.getSamplePromises();
  }

  /// Remove a promise from the list by ID
  void _removePromise(String promiseId) {
    setState(() {
      _todayPromises.removeWhere((promise) => promise.id == promiseId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Promise removed'),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppStyles.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppStyles.borderRadiusSmallAll,
        ),
      ),
    );
  }

  /// Navigate to selected bottom nav item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Build the Home tab content (Today's Promises)
  Widget _buildHomeTab(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isSmallScreen
            ? AppStyles.paddingMedium
            : AppStyles.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppStyles.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Today\'s Promises',
                  style: AppStyles.headingLarge.copyWith(
                    fontSize: isSmallScreen ? 24 : 28,
                  ),
                ),
                const SizedBox(height: AppStyles.paddingSmall),
                Text(
                  '${_todayPromises.length} commitments for today',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppStyles.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppStyles.paddingLarge),

          // Profile/Mascot Card with Network Image
          _buildProfileCard(context, isSmallScreen),
          const SizedBox(height: AppStyles.paddingXLarge),

          // Promises List
          if (_todayPromises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppStyles.paddingXLarge,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppStyles.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppStyles.primaryPurple.withOpacity(0.1),
                      borderRadius: AppStyles.borderRadiusLargeAll,
                    ),
                    child: const Icon(
                      Icons.done_all,
                      size: 48,
                      color: AppStyles.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingLarge),
                  Text(
                    'All caught up!',
                    style: AppStyles.headingMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppStyles.paddingSmall),
                  Text(
                    'You\'ve completed all your promises for today.',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppStyles.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _todayPromises.length,
              itemBuilder: (context, index) {
                return _buildPromiseCard(
                  context,
                  _todayPromises[index],
                  isSmallScreen,
                );
              },
            ),
        ],
      ),
    );
  }

  /// Build profile/mascot card with network image
  Widget _buildProfileCard(BuildContext context, bool isSmallScreen) {
    return Card(
      color: AppStyles.primaryPurple,
      elevation: AppStyles.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.borderRadiusLargeAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Row(
          children: [
            // Network Image
            Container(
              width: isSmallScreen ? 80 : 100,
              height: isSmallScreen ? 80 : 100,
              decoration: BoxDecoration(
                color: AppStyles.white.withOpacity(0.2),
                borderRadius: AppStyles.borderRadiusLargeAll,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://i.pinimg.com/originals/8e/83/b5/8e83b521bbd7c9f3fc5f35a4d99fd744.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Image.network(
                'https://i.pinimg.com/originals/8e/83/b5/8e83b521bbd7c9f3fc5f35a4d99fd744.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppStyles.white.withOpacity(0.2),
                      borderRadius: AppStyles.borderRadiusLargeAll,
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppStyles.white,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: AppStyles.white.withOpacity(0.2),
                      borderRadius: AppStyles.borderRadiusLargeAll,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppStyles.white),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppStyles.paddingLarge),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep Going!',
                    style: AppStyles.headingSmall.copyWith(
                      color: AppStyles.white,
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingSmall),
                  Text(
                    'You\'re doing great today. Stay focused on your goals!',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppStyles.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual promise card with delete functionality
  Widget _buildPromiseCard(
    BuildContext context,
    PromiseModel promise,
    bool isSmallScreen,
  ) {
    // Determine priority color
    Color priorityColor;
    switch (promise.priority) {
      case 5:
        priorityColor = AppStyles.errorRed;
        break;
      case 4:
        priorityColor = AppStyles.warningOrange;
        break;
      case 3:
        priorityColor = AppStyles.infoBlue;
        break;
      default:
        priorityColor = AppStyles.successGreen;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
      child: Card(
        elevation: AppStyles.cardElevation,
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.paddingMedium),
          child: Row(
            children: [
              // Priority Indicator
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: AppStyles.paddingMedium),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            promise.title,
                            style: AppStyles.labelLarge.copyWith(
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppStyles.paddingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: AppStyles.borderRadiusSmallAll,
                          ),
                          child: Text(
                            'P${promise.priority}',
                            style: AppStyles.labelSmall.copyWith(
                              color: priorityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.paddingSmall),
                    Text(
                      promise.description,
                      style: AppStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppStyles.paddingSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: AppStyles.iconSizeSmall,
                          color: AppStyles.mediumGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          promise.category,
                          style: AppStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete Button
              Padding(
                padding: const EdgeInsets.only(
                  left: AppStyles.paddingMedium,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppStyles.errorRed,
                  onPressed: () => _removePromise(promise.id),
                  tooltip: 'Remove promise',
                  splashRadius: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Friends tab placeholder
  Widget _buildFriendsTab() {
    return const FriendsScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promise'),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              tooltip: 'Settings',
            ),
        ],
      ),
      body: [
        _buildHomeTab(context),
        const ScheduleScreen(),
        const PromisesScreen(),
        const FriendsScreen(),
        const StoreScreen(),
        const AchievementsScreen(),
        const ProfileScreen(),
      ][_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box),
            label: 'Promises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            activeIcon: Icon(Icons.card_giftcard),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Awards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
