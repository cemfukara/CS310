import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';
import '../providers/promise_provider.dart';
import '../models/promise_model.dart';

/// Schedule Screen - Calendar and daily events from Firebase
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
    // DateTime.weekday returns 1 for Mon, 7 for Sun.
    // We want 0 for Sun, 1 for Mon... to match our UI grid.
    final weekday = DateTime(date.year, date.month, 1).weekday;
    return weekday == 7 ? 0 : weekday;
  }

  /// Helper to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Filter promises for the selected date
  List<PromiseModel> _getEventsForDate(List<PromiseModel> allPromises, DateTime date) {
    return allPromises.where((promise) {
      // 1. If it's a one-time event, dates must match exactly
      if (!promise.isRecursive) {
        return _isSameDay(promise.startTime, date);
      }

      // 2. If it's recursive (Weekly), it shows up if:
      //    a. The selected date is AFTER or SAME as the start date
      //    b. The weekdays match (e.g., both are Monday)
      if (promise.isRecursive) {
        final isAfterStart = date.isAtSameMomentAs(promise.startTime) || date.isAfter(promise.startTime);
        final isSameWeekday = promise.startTime.weekday == date.weekday;
        return isAfterStart && isSameWeekday;
      }

      return false;
    }).toList();
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
              return const SizedBox.shrink();
            }

            final day = index - firstWeekday + 1;
            final date = DateTime(_currentMonth.year, _currentMonth.month, day);

            final isToday = _isSameDay(date, DateTime.now());
            final isSelected = _isSameDay(date, _selectedDate);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
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

  /// Build event item
  Widget _buildEventItem(PromiseModel promise) {
    // Format times (e.g. "09:00 - 10:00")
    final timeStr = '${DateFormat('HH:mm').format(promise.startTime)} - ${DateFormat('HH:mm').format(promise.endTime)}';

    // Determine color based on completion
    final color = promise.isCompleted ? AppStyles.successGreen : AppStyles.primaryPurple;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
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
                    promise.title,
                    style: AppStyles.bodyLarge.copyWith(
                      decoration: promise.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppStyles.mediumGray),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: AppStyles.bodySmall,
                      ),
                      if (promise.isRecursive) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.repeat, size: 14, color: AppStyles.mediumGray),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            if (promise.isCompleted)
              const Icon(Icons.check_circle, color: AppStyles.successGreen),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Consumer<PromiseProvider>(
      builder: (context, promiseProvider, child) {
        // Get events for the selected date
        final dailyEvents = _getEventsForDate(promiseProvider.promises, _selectedDate);
        // Sort by time
        dailyEvents.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));

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
                      DateFormat('MMMM yyyy').format(_currentMonth),
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

                // Events Section Header
                Text(
                  'Events for ${DateFormat('MMMM d').format(_selectedDate)}',
                  style: AppStyles.headingSmall,
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Real Events List
                if (dailyEvents.isEmpty)
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
                          'Enjoy your free time!',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppStyles.mediumGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...dailyEvents.map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildEventItem(event),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }
}