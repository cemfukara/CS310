import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/gamification_provider.dart';

/// Achievements Screen - Display user achievements and progress
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final List<Map<String, dynamic>> _achievements = [
    {
      'id': 'first_promise',
      'name': 'First Promise',
      'description': 'Create your first promise',
      'icon': Icons.flag,
      'target': 1,
    },
    {
      'id': 'promise_master',
      'name': 'Promise Master',
      'description': 'Complete 50 promises',
      'icon': Icons.military_tech,
      'target': 50,
    },
    {
      'id': 'week_warrior',
      'name': 'Week Warrior',
      'description': 'Maintain a 7-day streak',
      'icon': Icons.whatshot,
      'target': 7,
    },
    {
      'id': 'consistency_king',
      'name': 'Consistency King',
      'description': 'Maintain a 30-day streak',
      'icon': Icons.star,
      'target': 30,
    },
    {
      'id': 'social_butterfly',
      'name': 'Social Butterfly',
      'description': 'Have 10 friends',
      'icon': Icons.group,
      'target': 10,
    },
    {
      'id': 'collector',
      'name': 'Collector',
      'description': 'Collect 20 badges',
      'icon': Icons.card_giftcard,
      'target': 20,
    },
    {
      'id': 'perfect_day',
      'name': 'Perfect Day',
      'description': 'Complete all promises in one day',
      'icon': Icons.calendar_today,
      'target': 1,
    },
    {
      'id': 'century_club',
      'name': 'Century Club',
      'description': 'Complete 100 promises',
      'icon': Icons.workspace_premium,
      'target': 100,
    },
  ];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, provider, child) {
        // Calculate dynamic stats based on provider data
        int unlockedCount = 0;
        for (var a in _achievements) {
          if (provider.hasAchievement(a['id'])) {
            unlockedCount++;
          }
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        final totalCount = _achievements.length;
        final completionPercentage = totalCount > 0
            ? ((unlockedCount / totalCount) * 100).toInt()
            : 0;

        return Scaffold(
          appBar: AppBar(title: const Text('Achievements'), centerTitle: true),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(
              isSmallScreen ? AppStyles.paddingMedium : AppStyles.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyles.paddingLarge),
                    child: Column(
                      children: [
                        Text('Overall Progress', style: AppStyles.headingSmall),
                        const SizedBox(height: AppStyles.paddingMedium),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: unlockedCount / totalCount,
                                strokeWidth: 8,
                                backgroundColor: AppStyles.nearWhite,
                                valueColor: AlwaysStoppedAnimation(
                                  AppStyles.primaryPurple,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '$unlockedCount/$totalCount',
                                  style: AppStyles.headingSmall,
                                ),
                                Text(
                                  '$completionPercentage%',
                                  style: AppStyles.labelMedium.copyWith(
                                    color: AppStyles.darkGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppStyles.paddingLarge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('Unlocked', style: AppStyles.labelMedium),
                                Text(
                                  '$unlockedCount',
                                  style: AppStyles.headingMedium,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Locked', style: AppStyles.labelMedium),
                                Text(
                                  '${totalCount - unlockedCount}',
                                  style: AppStyles.headingMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppStyles.paddingLarge),

                // Filter Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['All', 'Unlocked', 'Locked'].map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingSmall,
                      ),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        selectedColor: AppStyles.primaryPurple,
                        labelStyle: AppStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppStyles.white
                              : AppStyles.darkGray,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppStyles.paddingLarge),

                // Achievements List
                ..._buildAchievementsList(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAchievementsList(GamificationProvider provider) {
    List<Map<String, dynamic>> filteredAchievements;

    if (_selectedFilter == 'Unlocked') {
      filteredAchievements = _achievements
          .where((a) => provider.hasAchievement(a['id']))
          .toList();
    } else if (_selectedFilter == 'Locked') {
      filteredAchievements = _achievements
          .where((a) => !provider.hasAchievement(a['id']))
          .toList();
    } else {
      filteredAchievements = _achievements;
    }

    if (filteredAchievements.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppStyles.paddingXLarge,
            ),
            child: Text(
              'No achievements to display',
              style: AppStyles.bodyMedium,
            ),
          ),
        ),
      ];
    }

    return filteredAchievements.map((achievement) {
      final isUnlocked = provider.hasAchievement(achievement['id']);
      final progress = provider.getAchievementProgress(achievement['id']);
      final target = achievement['target'] as int;
      final progressPercent = (progress / target).clamp(0.0, 1.0);

      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
        child: GestureDetector(
          onTap: () => _showAchievementDetails(achievement, isUnlocked),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingMedium),
              child: Row(
                children: [
                  // Achievement Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppStyles.primaryPurple.withOpacity(0.1)
                          : AppStyles.lightGray,
                      borderRadius: AppStyles.borderRadiusMediumAll,
                      border: Border.all(
                        color: isUnlocked
                            ? AppStyles.primaryPurple
                            : AppStyles.mediumGray,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          achievement['icon'],
                          color: isUnlocked
                              ? AppStyles.primaryPurple
                              : AppStyles.mediumGray,
                          size: 40,
                        ),
                        if (isUnlocked)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppStyles.successGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppStyles.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: AppStyles.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppStyles.paddingMedium),

                  // Achievement Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(achievement['name'], style: AppStyles.bodyLarge),
                        const SizedBox(height: 4),
                        Text(
                          achievement['description'],
                          style: AppStyles.bodySmall,
                        ),
                        const SizedBox(height: AppStyles.paddingSmall),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: AppStyles.borderRadiusSmallAll,
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 6,
                            backgroundColor: AppStyles.nearWhite,
                            valueColor: AlwaysStoppedAnimation(
                              isUnlocked
                                  ? AppStyles.successGreen
                                  : AppStyles.primaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('$progress/$target', style: AppStyles.labelSmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppStyles.paddingMedium),

                  // Unlock Date or Lock Icon
                  if (isUnlocked)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: AppStyles.warningOrange,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement['unlockedDate'] ?? '',
                          style: AppStyles.labelSmall,
                        ),
                      ],
                    )
                  else
                    Icon(Icons.lock, color: AppStyles.mediumGray),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showAchievementDetails(
    Map<String, dynamic> achievement,
    bool isUnlocked,
  ) {
    final provider = Provider.of<GamificationProvider>(context, listen: false);
    int progress = provider.getAchievementProgress(achievement['id']);
    int target = achievement['target'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                achievement['icon'],
                size: 64,
                color: isUnlocked
                    ? AppStyles.primaryPurple
                    : AppStyles.mediumGray,
              ),
            ),
            const SizedBox(height: AppStyles.paddingLarge),
            Text('Description', style: AppStyles.bodyLarge),
            Text(achievement['description'], style: AppStyles.bodyMedium),
            const SizedBox(height: AppStyles.paddingLarge),
            Text('Progress', style: AppStyles.bodyLarge),
            const SizedBox(height: AppStyles.paddingSmall),
            ClipRRect(
              borderRadius: AppStyles.borderRadiusSmallAll,
              child: LinearProgressIndicator(
                value: (progress / target).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppStyles.nearWhite,
                valueColor: AlwaysStoppedAnimation(
                  isUnlocked ? AppStyles.successGreen : AppStyles.primaryPurple,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('$progress/$target', style: AppStyles.bodySmall),
            const SizedBox(height: AppStyles.paddingLarge),
            if (isUnlocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppStyles.successGreen.withOpacity(0.1),
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppStyles.successGreen),
                    const SizedBox(width: AppStyles.paddingSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unlocked', style: AppStyles.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
}
