import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';
import '../providers/promise_provider.dart';
import '../models/promise_model.dart';

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

  int _getDaysInMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0).day;

  int _getFirstWeekday(DateTime date) {
    final weekday = DateTime(date.year, date.month, 1).weekday;
    return weekday == 7 ? 0 : weekday;
  }

  bool _hasEventsForDate(List<PromiseModel> allPromises, DateTime date) {
    return _getEventsForDate(allPromises, date).isNotEmpty;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<PromiseModel> _getEventsForDate(
    List<PromiseModel> allPromises,
    DateTime date,
  ) {
    return allPromises.where((promise) {
      if (!promise.isRecursive) {
        return _isSameDay(promise.startTime, date);
      }
      final isAfterStart =
          date.isAtSameMomentAs(promise.startTime) ||
          date.isAfter(promise.startTime);
      final isSameWeekday = promise.startTime.weekday == date.weekday;
      return isAfterStart && isSameWeekday;
    }).toList();
  }

  Widget _buildEventItem(PromiseModel promise) {
    final timeStr =
        '${DateFormat('HH:mm').format(promise.startTime)} - ${DateFormat('HH:mm').format(promise.endTime)}';
    final color = promise.isCompleted
        ? AppStyles.successGreen
        : AppStyles.primaryPurple;

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
                      decoration: promise.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppStyles.mediumGray,
                      ),
                      const SizedBox(width: 4),
                      Text(timeStr, style: AppStyles.bodySmall),
                      if (promise.isRecursive) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: AppStyles.mediumGray,
                        ),
                      ],
                    ],
                  ),
                  if (promise.sharedBy != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppStyles.primaryPurple,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Shared by ${promise.sharedBy}',
                            style: AppStyles.bodySmall.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppStyles.primaryPurple,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                promise.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: promise.isCompleted
                    ? AppStyles.successGreen
                    : AppStyles.mediumGray,
              ),
              onPressed: promise.isCompleted
                  ? null
                  : () {
                      Provider.of<PromiseProvider>(
                        context,
                        listen: false,
                      ).toggleStatus(promise.id, !promise.isCompleted);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List<PromiseModel> promises) {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstWeekday = _getFirstWeekday(_currentMonth);
    final totalCells = firstWeekday + daysInMonth;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: AppStyles.labelMedium.copyWith(
                      color: AppStyles.mediumGray,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppStyles.paddingSmall),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox.shrink();
            final day = index - firstWeekday + 1;
            final date = DateTime(_currentMonth.year, _currentMonth.month, day);
            final isToday = _isSameDay(date, DateTime.now());
            final isSelected = _isSameDay(date, _selectedDate);
            final hasEvents = _hasEventsForDate(promises, date);

            return GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppStyles.primaryPurple
                      : isToday
                      ? AppStyles.primaryPurple.withOpacity(0.2)
                      : hasEvents
                      ? AppStyles.infoBlue.withOpacity(0.2)
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PromiseProvider>(
      builder: (context, promiseProvider, child) {
        final dailyEvents = _getEventsForDate(
          promiseProvider.promises,
          _selectedDate,
        );
        dailyEvents.sort(
          (a, b) => a.startTime.hour.compareTo(b.startTime.hour),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Schedule'),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(
                        () => _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: AppStyles.headingSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(
                        () => _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyles.paddingLarge),
                _buildCalendarGrid(promiseProvider.promises),
                const SizedBox(height: AppStyles.paddingXLarge),
                Text(
                  'Events for ${DateFormat('MMMM d').format(_selectedDate)}',
                  style: AppStyles.headingSmall,
                ),
                const SizedBox(height: AppStyles.paddingMedium),
                if (dailyEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No events scheduled."),
                    ),
                  )
                else
                  ...dailyEvents.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildEventItem(event),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
