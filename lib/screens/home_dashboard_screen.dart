import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/promise_provider.dart'; // Import PromiseProvider
import '../models/promise_model.dart';
import '../utils/app_styles.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';
import 'promises_screen.dart';
import 'friends_screen.dart';
import 'store_inventory_screen.dart';
import 'achievements_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLastTab();
  }

  Future<void> _loadLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('last_tab') ?? 0;
    });
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_tab', index);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToStore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StoreInventoryScreen()),
    );
  }

  void _navigateToAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AchievementsScreen()),
    );
  }

  // --- DELETE FUNCTION ---
  void _deletePromise(BuildContext context, String promiseId) async {
    try {
      // Call the provider to delete from Firebase
      await Provider.of<PromiseProvider>(
        context,
        listen: false,
      ).deletePromise(promiseId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promise deleted'),
            backgroundColor: AppStyles.successGreen,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppStyles.errorRed,
          ),
        );
      }
    }
  }

  // --- HOME TAB (REAL DATA + REFRESH) ---
  Widget _buildHomeTab(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Consumer<PromiseProvider>(
      builder: (context, promiseProvider, child) {
        // 1. Check Loading State
        if (promiseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final promises = promiseProvider.promises;

        // 2. Wrap in RefreshIndicator for Pull-to-Refresh
        return RefreshIndicator(
          onRefresh: () async {
            await promiseProvider.reload();
          },
          child: SingleChildScrollView(
            // AlwaysScrollableScrollPhysics ensures pull-to-refresh works even if list is short
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(
              isSmallScreen ? AppStyles.paddingMedium : AppStyles.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppStyles.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Today\'s Promises', style: AppStyles.headingLarge),
                      const SizedBox(height: AppStyles.paddingSmall),
                      Text(
                        '${promises.length} commitments total',
                        style: AppStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyles.paddingLarge),

                // Profile Card (Now acts as a Stat Summary / Welcome)
                _buildWelcomeCard(context, isSmallScreen),
                const SizedBox(height: AppStyles.paddingLarge),

                // Gamification Quick Access (Store & Achievements)
                _buildGamificationRow(),
                const SizedBox(height: AppStyles.paddingXLarge),

                // Promises List (Real Data)
                if (promises.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: promises.length,
                    itemBuilder: (context, index) {
                      return _buildPromiseCard(context, promises[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
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
        Text('No promises found', style: AppStyles.headingMedium),
        const SizedBox(height: AppStyles.paddingSmall),
        Text(
          'Tap the + button to create your first promise!',
          style: AppStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool isSmallScreen) {
    return Card(
      color: AppStyles.primaryPurple,
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppStyles.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: AppStyles.paddingLarge),
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
                  const SizedBox(height: 4),
                  Text(
                    'Stay focused on your goals.',
                    style: AppStyles.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationRow() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAccessCard(
            icon: Icons.store,
            title: 'Store',
            color: AppStyles.warningOrange,
            onTap: _navigateToStore,
          ),
        ),
        const SizedBox(width: AppStyles.paddingMedium),
        Expanded(
          child: _buildQuickAccessCard(
            icon: Icons.emoji_events,
            title: 'Awards',
            color: AppStyles.secondaryTeal,
            onTap: _navigateToAchievements,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        decoration: BoxDecoration(
          color: AppStyles.white,
          borderRadius: AppStyles.borderRadiusMediumAll,
          boxShadow: AppStyles.shadowSmall,
          border: Border.all(color: AppStyles.lightGray),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title, style: AppStyles.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseCard(BuildContext context, PromiseModel promise) {
    Color priorityColor;
    if (promise.isCompleted) {
      priorityColor = Colors.green[800]!; // Dark Green for completed
    } else if (promise.priority >= 5) {
      priorityColor = AppStyles.errorRed;
    } else if (promise.priority == 4) {
      priorityColor = AppStyles.warningOrange;
    } else if (promise.priority == 3) {
      priorityColor = AppStyles.infoBlue;
    } else {
      priorityColor = AppStyles.successGreen;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
      child: ListTile(
        leading: Container(width: 4, height: 50, color: priorityColor),
        title: Text(
          promise.title,
          style: AppStyles.labelLarge.copyWith(color: Colors.black87),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promise.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              promise.category,
              style: AppStyles.bodySmall.copyWith(
                color: AppStyles.primaryPurple,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                promise.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: promise.isCompleted
                    ? AppStyles.successGreen
                    : AppStyles.mediumGray,
              ),
              onPressed: () {
                Provider.of<PromiseProvider>(
                  context,
                  listen: false,
                ).toggleStatus(promise.id, !promise.isCompleted);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppStyles.errorRed),
              onPressed: () => _deletePromise(context, promise.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only 4 main tabs now
    final List<Widget> pages = [
      _buildHomeTab(context),
      const ScheduleScreen(),
      const PromisesScreen(),
      const FriendsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promise'),
        actions: [
          // Profile relocated to AppBar
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _navigateToProfile,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/new-promise');
              if (mounted) {
                Provider.of<PromiseProvider>(context, listen: false).reload();
              }
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Promises'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
        ],
      ),
    );
  }
}
