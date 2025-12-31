import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Achievements Screen - Display user achievements and progress
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final List<Map<String, dynamic>> _achievements = [
    {
      'name': 'First Promise',
      'description': 'Create your first promise',
      'icon': Icons.flag,
      'unlocked': true,
      'unlockedDate': '2025-01-15',
      'progress': 1,
      'target': 1,
    },
    {
      'name': 'Promise Master',
      'description': 'Complete 50 promises',
      'icon': Icons.military_tech,
      'unlocked': true,
      'unlockedDate': '2025-11-10',
      'progress': 50,
      'target': 50,
    },
    {
      'name': 'Week Warrior',
      'description': 'Maintain a 7-day streak',
      'icon': Icons.whatshot,
      'unlocked': true,
      'unlockedDate': '2025-11-15',
      'progress': 7,
      'target': 7,
    },
    {
      'name': 'Consistency King',
      'description': 'Maintain a 30-day streak',
      'icon': Icons.star,
      'unlocked': false,
      'unlockedDate': null,
      'progress': 18,
      'target': 30,
    },
    {
      'name': 'Social Butterfly',
      'description': 'Have 10 friends',
      'icon': Icons.group,
      'unlocked': false,
      'unlockedDate': null,
      'progress': 6,
      'target': 10,
    },
    {
      'name': 'Collector',
      'description': 'Collect 20 badges',
      'icon': Icons.card_giftcard,
      'unlocked': false,
      'unlockedDate': null,
      'progress': 8,
      'target': 20,
    },
    {
      'name': 'Perfect Day',
      'description': 'Complete all promises in one day',
      'icon': Icons.calendar_today,
      'unlocked': true,
      'unlockedDate': '2025-11-20',
      'progress': 1,
      'target': 1,
    },
    {
      'name': 'Century Club',
      'description': 'Complete 100 promises',
      'icon': Icons.workspace_premium,
      'unlocked': false,
      'unlockedDate': null,
      'progress': 50,
      'target': 100,
    },
  ];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final unlockedCount = _achievements
        .where((a) => a['unlocked'] == true)
        .length;
    final totalCount = _achievements.length;
    final completionPercentage = ((unlockedCount / totalCount) * 100).toInt();

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
                      color: isSelected ? AppStyles.white : AppStyles.darkGray,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppStyles.paddingLarge),

            // Achievements List
            ..._buildAchievementsList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAchievementsList() {
    List<Map<String, dynamic>> filteredAchievements;

    if (_selectedFilter == 'Unlocked') {
      filteredAchievements = _achievements
          .where((a) => a['unlocked'] == true)
          .toList();
    } else if (_selectedFilter == 'Locked') {
      filteredAchievements = _achievements
          .where((a) => a['unlocked'] == false)
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
      final isUnlocked = achievement['unlocked'] as bool;
      final progress = achievement['progress'] as int;
      final target = achievement['target'] as int;
      final progressPercent = (progress / target).clamp(0.0, 1.0);

      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
        child: GestureDetector(
          onTap: () => _showAchievementDetails(achievement),
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

  void _showAchievementDetails(Map<String, dynamic> achievement) {
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
                color: achievement['unlocked']
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
                value: (achievement['progress'] / achievement['target']).clamp(
                  0.0,
                  1.0,
                ),
                minHeight: 8,
                backgroundColor: AppStyles.nearWhite,
                valueColor: AlwaysStoppedAnimation(
                  achievement['unlocked']
                      ? AppStyles.successGreen
                      : AppStyles.primaryPurple,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${achievement['progress']}/${achievement['target']}',
              style: AppStyles.bodySmall,
            ),
            const SizedBox(height: AppStyles.paddingLarge),
            if (achievement['unlocked'])
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
                          Text(
                            'On ${achievement['unlockedDate']}',
                            style: AppStyles.bodySmall,
                          ),
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
