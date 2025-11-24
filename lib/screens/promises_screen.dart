import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'new_promise_screen.dart';
import 'edit_promise_screen.dart';

/// Promises Screen - View all promises across all categories
class PromisesScreen extends StatefulWidget {
  const PromisesScreen({super.key});

  @override
  State<PromisesScreen> createState() => _PromisesScreenState();
}

class _PromisesScreenState extends State<PromisesScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Work', 'Personal', 'Health', 'Family'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Promises'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewPromiseScreen(),
                ),
              );
            },
            tooltip: 'Create New Promise',
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
            // Category Filter
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: AppStyles.paddingSmall),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: AppStyles.nearWhite,
                      selectedColor: AppStyles.primaryPurple,
                      labelStyle: AppStyles.labelMedium.copyWith(
                        color: isSelected ? AppStyles.white : AppStyles.darkGray,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppStyles.paddingLarge),

            // Promise Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: '12',
                    color: AppStyles.successGreen,
                  ),
                ),
                const SizedBox(width: AppStyles.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.hourglass_bottom,
                    label: 'In Progress',
                    value: '8',
                    color: AppStyles.infoBlue,
                  ),
                ),
                const SizedBox(width: AppStyles.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.pending,
                    label: 'Pending',
                    value: '5',
                    color: AppStyles.warningOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Promises List
            Text(
              'All Promises',
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            ..._buildPromisesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: AppStyles.iconSizeLarge),
            const SizedBox(height: AppStyles.paddingSmall),
            Text(value, style: AppStyles.headingSmall.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPromisesList() {
    final promises = [
      {'title': 'Complete Quarterly Report', 'category': 'Work', 'status': 'In Progress'},
      {'title': 'Call Parents Weekly', 'category': 'Family', 'status': 'Completed'},
      {'title': 'Gym 3x Per Week', 'category': 'Health', 'status': 'In Progress'},
      {'title': 'Read 1 Book', 'category': 'Personal', 'status': 'Completed'},
      {'title': 'Team Building Event', 'category': 'Work', 'status': 'Pending'},
      {'title': 'Meditation Daily', 'category': 'Personal', 'status': 'In Progress'},
    ];

    return promises.map((promise) {
      Color statusColor;
      IconData statusIcon;

      switch (promise['status']) {
        case 'Completed':
          statusColor = AppStyles.successGreen;
          statusIcon = Icons.check_circle;
          break;
        case 'In Progress':
          statusColor = AppStyles.infoBlue;
          statusIcon = Icons.schedule;
          break;
        default:
          statusColor = AppStyles.warningOrange;
          statusIcon = Icons.pending;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: AppStyles.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(promise['title']!, style: AppStyles.bodyLarge),
                      const SizedBox(height: 4),
                      Text(
                        promise['category']!,
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: AppStyles.borderRadiusSmallAll,
                  ),
                  child: Text(
                    promise['status']!,
                    style: AppStyles.labelSmall.copyWith(color: statusColor),
                  ),
                ),
                const SizedBox(width: AppStyles.paddingSmall),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: AppStyles.primaryPurple,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditPromiseScreen(),
                      ),
                    );
                  },
                  tooltip: 'Edit Promise',
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
