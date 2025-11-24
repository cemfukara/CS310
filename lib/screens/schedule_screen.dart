import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Schedule Screen - Calendar and daily events placeholder
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonth = DateTime.now();
  }

  /// Get the number of days in a month
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Get the weekday of the first day of the month (0 = Sunday, 6 = Saturday)
  int _getFirstWeekday(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  /// Build calendar grid
  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstWeekday = _getFirstWeekday(_currentMonth);
    final totalCells = firstWeekday + daysInMonth;

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map(
                (day) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppStyles.paddingSmall,
                    ),
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: AppStyles.labelMedium.copyWith(
                        color: AppStyles.mediumGray,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppStyles.paddingSmall),

        // Calendar days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            mainAxisSpacing: AppStyles.paddingSmall,
            crossAxisSpacing: AppStyles.paddingSmall,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < firstWeekday) {
              // Empty cells before the first day
              return const SizedBox.shrink();
            }

            final day = index - firstWeekday + 1;
            final isToday = day == DateTime.now().day &&
                _currentMonth.month == DateTime.now().month &&
                _currentMonth.year == DateTime.now().year;
            final isSelected = day == _selectedDate.day &&
                _currentMonth.month == _selectedDate.month &&
                _currentMonth.year == _selectedDate.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    day,
                  );
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppStyles.primaryPurple
                      : isToday
                          ? AppStyles.primaryPurple.withOpacity(0.2)
                          : AppStyles.nearWhite,
                  borderRadius: AppStyles.borderRadiusSmallAll,
                  border: Border.all(
                    color: isToday
                        ? AppStyles.primaryPurple
                        : AppStyles.lightGray,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: AppStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppStyles.white
                          : isToday
                              ? AppStyles.primaryPurple
                              : AppStyles.darkGray,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build sample event item
  Widget _buildEventItem(String title, String time, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: AppStyles.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: AppStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        centerTitle: true,
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
            // Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: AppStyles.primaryPurple,
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][_currentMonth.month - 1]} ${_currentMonth.year}',
                  style: AppStyles.headingSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: AppStyles.primaryPurple,
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppStyles.paddingLarge),

            // Calendar Grid
            Container(
              padding: const EdgeInsets.all(AppStyles.paddingMedium),
              decoration: BoxDecoration(
                color: AppStyles.nearWhite,
                borderRadius: AppStyles.borderRadiusMediumAll,
                border: Border.all(
                  color: AppStyles.lightGray,
                  width: 1,
                ),
              ),
              child: _buildCalendarGrid(),
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Events Section
            Text(
              'Events for ${_selectedDate.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][_selectedDate.month - 1]}',
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: AppStyles.paddingMedium),

            // Sample Events
            _buildEventItem(
              'Team Meeting',
              '09:00 AM - 10:00 AM',
              AppStyles.primaryPurple,
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            _buildEventItem(
              'Project Review',
              '02:00 PM - 03:30 PM',
              AppStyles.accentBlue,
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            _buildEventItem(
              'Lunch Break',
              '12:00 PM - 01:00 PM',
              AppStyles.successGreen,
            ),
            const SizedBox(height: AppStyles.paddingLarge),

            // No events message (shown when list is empty)
            if (false)
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
                        Icons.event_available_outlined,
                        size: 48,
                        color: AppStyles.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: AppStyles.paddingLarge),
                    Text(
                      'No events scheduled',
                      style: AppStyles.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppStyles.paddingSmall),
                    Text(
                      'Add a new event to get started',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppStyles.mediumGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
