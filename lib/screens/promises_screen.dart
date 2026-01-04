import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';
import '../providers/promise_provider.dart';
import '../models/promise_model.dart';

class PromisesScreen extends StatefulWidget {
  const PromisesScreen({super.key});

  @override
  State<PromisesScreen> createState() => _PromisesScreenState();
}

class _PromisesScreenState extends State<PromisesScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Work',
    'Personal',
    'Health',
    'Family',
  ];

  String _getStatus(PromiseModel promise) {
    if (promise.isCompleted) return 'Completed';

    if (promise.isRecursive) {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (promise.completedDates.contains(todayStr)) return 'Completed';
    }

    if (DateTime.now().isAfter(promise.endTime)) return 'Overdue';
    return 'In Progress';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppStyles.successGreen;
      case 'Overdue':
        return AppStyles.errorRed;
      case 'In Progress':
      default:
        return AppStyles.infoBlue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle;
      case 'Overdue':
        return Icons.error_outline;
      case 'In Progress':
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Consumer<PromiseProvider>(
      builder: (context, promiseProvider, child) {
        final allPromises = promiseProvider.promises;

        int overdueCount = 0;
        int completedCount = 0;
        int inProgressCount = 0;

        for (var p in allPromises) {
          String status = _getStatus(p);
          if (status == 'Completed')
            completedCount++;
          else if (status == 'In Progress')
            inProgressCount++;
          else if (status == 'Overdue')
            overdueCount++;
        }

        final categoryFilteredPromises = _selectedCategory == 'All'
            ? allPromises
            : allPromises
                  .where((p) => p.category == _selectedCategory)
                  .toList();

        final activePromises = categoryFilteredPromises
            .where((p) => !p.isCompleted)
            .toList();
        final completedPromises = categoryFilteredPromises
            .where((p) => p.isCompleted)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('All Promises'),
            centerTitle: true,
            // --- ADDED ACTIONS ---
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/new-promise');
                  if (mounted) {
                    Provider.of<PromiseProvider>(
                      context,
                      listen: false,
                    ).reload();
                  }
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await promiseProvider.reload();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(
                isSmallScreen
                    ? AppStyles.paddingMedium
                    : AppStyles.paddingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Category Filter ---
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

                  // --- Stats Row ---
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

                  // ---------------- ACTIVE PROMISES SECTION ----------------
                  Text('Active Promises', style: AppStyles.headingSmall),
                  const SizedBox(height: AppStyles.paddingMedium),

                  if (promiseProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (activePromises.isEmpty)
                    _buildEmptySection("No active promises.")
                  else
                    ..._buildRealPromisesList(
                      context,
                      activePromises,
                      promiseProvider,
                    ),

                  const SizedBox(height: AppStyles.paddingXLarge),

                  // ---------------- COMPLETED PROMISES SECTION ----------------
                  Text('Completed Promises', style: AppStyles.headingSmall),
                  const SizedBox(height: AppStyles.paddingMedium),

                  if (!promiseProvider.isLoading)
                    if (completedPromises.isEmpty)
                      _buildEmptySection("No completed promises yet.")
                    else
                      ..._buildRealPromisesList(
                        context,
                        completedPromises,
                        promiseProvider,
                      ),

                  const SizedBox(height: AppStyles.paddingXXLarge),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptySection(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(
          text,
          style: AppStyles.bodyMedium.copyWith(color: AppStyles.mediumGray),
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
                      Text(
                        promise.title,
                        style: AppStyles.bodyLarge.copyWith(
                          decoration: promise.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: promise.isCompleted
                              ? AppStyles.mediumGray
                              : AppStyles.darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(promise.category, style: AppStyles.bodySmall),
                          if (promise.sharedBy != null) ...[
                            const SizedBox(width: 8),
                            Text("|", style: AppStyles.bodySmall),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.person_outline,
                              size: 12,
                              color: AppStyles.primaryPurple,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                'Shared by ${promise.sharedBy}',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppStyles.primaryPurple,
                                  fontStyle: FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
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
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppStyles.errorRed,
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Promise'),
                        content: const Text(
                          'Are you sure you want to delete this promise? This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: AppStyles.errorRed),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      await provider.deletePromise(promise.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Promise deleted')),
                      );
                    }
                  },
                  tooltip: 'Delete Promise',
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
