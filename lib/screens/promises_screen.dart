import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/promise_provider.dart';
import '../models/promise_model.dart';

/// Promises Screen - View all promises across all categories
class PromisesScreen extends StatefulWidget {
  const PromisesScreen({super.key});

  @override
  State<PromisesScreen> createState() => _PromisesScreenState();
}

class _PromisesScreenState extends State<PromisesScreen> {
  String _selectedCategory = 'All';
  // You might want to fetch these dynamically later, but static is fine for now
  final List<String> _categories = [
    'All',
    'Work',
    'Personal',
    'Health',
    'Family',
    'Recurring',
    'One-time',
  ];

  // Helper to determine status string from model
  String _getStatus(PromiseModel promise) {
    if (promise.isCompleted) return 'Completed';

    final now = DateTime.now();
    if (now.isAfter(promise.startTime) && now.isBefore(promise.endTime)) {
      return 'In Progress';
    }
    if (now.isAfter(promise.endTime)) {
      return 'Overdue';
    }
    return 'Pending';
  }

  // Helper to get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppStyles.successGreen;
      case 'In Progress':
        return AppStyles.infoBlue;
      case 'Overdue':
        return AppStyles.errorRed;
      default:
        return AppStyles.warningOrange; // Pending
    }
  }

  // Helper to get icon based on status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle;
      case 'In Progress':
        return Icons.schedule;
      case 'Overdue':
        return Icons.error_outline;
      default:
        return Icons.pending; // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Consumer<PromiseProvider>(
      builder: (context, promiseProvider, child) {
        final allPromises = promiseProvider.promises;

        // 1. Calculate Stats
        int overdueCount = 0;
        int completedCount = 0;
        int inProgressCount = 0;

        for (var p in allPromises) {
          String status = _getStatus(p);
          if (status == 'Completed') {
            completedCount++;
          } else if (status == 'In Progress') {
            inProgressCount++;
          } else if (status == 'Overdue') {
            overdueCount++;
          }
        }

        // 2. Filter List based on Category
        final filteredPromises = _selectedCategory == 'All'
            ? allPromises
            : allPromises
                  .where((p) => p.category == _selectedCategory)
                  .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('All Promises'),
            centerTitle: true,
            // REMOVED: The actions block with the "+" button was here.
          ),
          // 3. Add Refresh Indicator
          body: RefreshIndicator(
            onRefresh: () async {
              await promiseProvider.reload();
            },
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh always works
              padding: EdgeInsets.all(
                isSmallScreen
                    ? AppStyles.paddingMedium
                    : AppStyles.paddingLarge,
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
                          padding: const EdgeInsets.only(
                            right: AppStyles.paddingSmall,
                          ),
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
                              color: isSelected
                                  ? AppStyles.white
                                  : AppStyles.darkGray,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppStyles.paddingLarge),

                  // Promise Stats (Real Data)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          label: 'Completed',
                          value: '$completedCount',
                          color: AppStyles.successGreen,
                        ),
                      ),
                      const SizedBox(width: AppStyles.paddingMedium),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.hourglass_bottom,
                          label: 'In Progress',
                          value: '$inProgressCount',
                          color: AppStyles.infoBlue,
                        ),
                      ),
                      const SizedBox(width: AppStyles.paddingMedium),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.error_outline,
                          label: 'Overdue',
                          value: '$overdueCount',
                          color: AppStyles.errorRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppStyles.paddingXLarge),

                  // Promises List Title
                  Text('All Promises', style: AppStyles.headingSmall),
                  const SizedBox(height: AppStyles.paddingMedium),

                  // Promises List (Real Data)
                  if (promiseProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (filteredPromises.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text("No promises found in this category."),
                      ),
                    )
                  else
                    ..._buildRealPromisesList(
                      context,
                      filteredPromises,
                      promiseProvider,
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
            Text(
              label,
              style: AppStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRealPromisesList(
    BuildContext context,
    List<PromiseModel> promises,
    PromiseProvider provider,
  ) {
    return promises.map((promise) {
      final status = _getStatus(promise);
      final statusColor = _getStatusColor(status);
      final statusIcon = _getStatusIcon(status);

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
                      Text(promise.title, style: AppStyles.bodyLarge),
                      const SizedBox(height: 4),
                      Text(promise.category, style: AppStyles.bodySmall),
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
                    status,
                    style: AppStyles.labelSmall.copyWith(color: statusColor),
                  ),
                ),
                const SizedBox(width: AppStyles.paddingSmall),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: AppStyles.primaryPurple,
                  onPressed: promise.isCompleted
                      ? null
                      : () async {
                          // Navigate to edit and refresh on return
                          await Navigator.pushNamed(
                            context,
                            '/edit-promise',
                            arguments: promise,
                          );
                          if (mounted) {
                            provider.reload();
                          }
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
