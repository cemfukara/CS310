import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../utils/app_styles.dart';

/// Edit Promise Screen - Edit an existing promise with slots and difficulty settings
class EditPromiseScreen extends StatefulWidget {
  const EditPromiseScreen({super.key});

  @override
  State<EditPromiseScreen> createState() => _EditPromiseScreenState();
}

class _EditPromiseScreenState extends State<EditPromiseScreen> {
  // --- DATE FORMAT CONSTANTS ---
  static const String fullDateTimeFormat = 'dd/MMM/yy HH:mm';
  static const String dayTimeFormat = 'EEE HH:mm';

  // --- STATE VARIABLES ---
  String selectedDifficultyPeriod = 'Total';
  int difficultyStars = 4;
  Map<String, int> difficultyTime = {'hours': 99, 'minutes': 30};

  List<Map<String, dynamic>> dynamicSlots = [
    {
      'start': DateTime.now().add(const Duration(days: 1, hours: 1)),
      'end': DateTime.now().add(const Duration(days: 1, hours: 3)),
      'completed': false,
      'is_recurring': false
    },
  ];

  // --- SLOT MANAGEMENT METHODS ---

  void _removeSlot(int index) {
    setState(() => dynamicSlots.removeAt(index));
  }

  void _addSlot() {
    setState(() {
      dynamicSlots.add({
        'start': null,
        'end': null,
        'completed': false,
        'is_recurring': false
      });
    });
  }

  void _toggleSlotCompletion(int index, bool? newValue) {
    setState(() => dynamicSlots[index]['completed'] = newValue ?? false);
  }

  void _toggleSlotRecurring(int index, bool newValue) {
    setState(() {
      dynamicSlots[index]['is_recurring'] = newValue;
      dynamicSlots[index]['start'] = null;
      dynamicSlots[index]['end'] = null;
    });
  }

  // --- DATE/TIME PICKER LOGIC ---

  Future<void> _pickFullDateTime(int index, String type) async {
    DateTime now = DateTime.now();
    DateTime? initialDateTime = dynamicSlots[index][type] as DateTime?;
    DateTime initialDate = initialDateTime ?? now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    _validateAndSetDateTime(index, type, finalDateTime);
  }

  Future<void> _pickDayTime(int index, String type) async {
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String? selectedDay = weekdays[0];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Day of Week'),
          content: DropdownButtonFormField<String>(
            value: selectedDay,
            items: weekdays
                .map((day) => DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    ))
                .toList(),
            onChanged: (newValue) {
              selectedDay = newValue;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedDay);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((resultDay) async {
      if (resultDay == null) return;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (pickedTime == null) return;

      DateTime now = DateTime.now();
      int currentWeekday = now.weekday;
      final int dayIndex = weekdays.indexOf(resultDay.toString());
      int targetWeekday = dayIndex + 1;
      DateTime targetDate = now.add(Duration(days: targetWeekday - currentWeekday));

      final DateTime finalDateTime = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _validateAndSetDateTime(index, type, finalDateTime);
    });
  }

  void _validateAndSetDateTime(int index, String type, DateTime finalDateTime) {
    setState(() {
      final currentPair = dynamicSlots[index];
      if (type == 'start') {
        final DateTime? endTime = currentPair['end'] as DateTime?;
        if (endTime != null && finalDateTime.isAfter(endTime)) {
          _showErrorSnackbar("Start Time cannot be after End Time.");
          return;
        }
        currentPair['start'] = finalDateTime;
      } else if (type == 'end') {
        final DateTime? startTime = currentPair['start'] as DateTime?;
        if (startTime != null && finalDateTime.isBefore(startTime)) {
          _showErrorSnackbar("End Time cannot be before Start Time.");
          return;
        }
        currentPair['end'] = finalDateTime;
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppStyles.errorRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _pickDifficultyTime() async {
    TextEditingController hoursController =
        TextEditingController(text: difficultyTime['hours'].toString());
    TextEditingController minutesController =
        TextEditingController(text: difficultyTime['minutes'].toString());

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Duration (hhh:mm)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: 'Hours'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(':', style: TextStyle(fontSize: 24)),
                  ),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: minutesController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: 'Minutes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Set'),
              onPressed: () {
                int hours = int.tryParse(hoursController.text) ?? 0;
                int minutes = int.tryParse(minutesController.text) ?? 0;
                if (hours > 999 || hours < 0) {
                  _showErrorSnackbar("Hours must be between 0 and 999.");
                  return;
                }
                if (minutes > 59 || minutes < 0) {
                  _showErrorSnackbar("Minutes must be between 0 and 59.");
                  return;
                }
                setState(() {
                  difficultyTime = {'hours': hours, 'minutes': minutes};
                  selectedDifficultyPeriod = 'Time';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardSection({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyles.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTimeSlotChip(String label, bool isSelected, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppStyles.primaryPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected ? Border.all(color: AppStyles.primaryPurple) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppStyles.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, Function(String) onTap) {
    final isSelected = selectedDifficultyPeriod == label;

    return InkWell(
      onTap: () => onTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppStyles.primaryPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: Icon(Icons.check, size: 16, color: AppStyles.white),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppStyles.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppStyles.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Your Promise',
          style: TextStyle(
            color: AppStyles.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 20, color: AppStyles.primaryPurple),
            _buildSlotsSection(),
            _buildDifficultySection(),
            const SizedBox(height: 30),
            _buildDoneButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsSection() {
    final List<Widget> children = [
      Row(
        children: const [
          Text(
            'Slots',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Icon(Icons.access_time, size: 18, color: Colors.grey),
        ],
      ),
      const SizedBox(height: 12),
    ];

    dynamicSlots.asMap().forEach((index, slotPair) {
      final DateTime? startTime = slotPair['start'] as DateTime?;
      final DateTime? endTime = slotPair['end'] as DateTime?;
      final bool isCompleted = slotPair['completed'] as bool;
      final bool isSlotRecurring = slotPair['is_recurring'] as bool;

      final String dateFormat = isSlotRecurring ? dayTimeFormat : fullDateTimeFormat;
      final Function pickFunction = isSlotRecurring ? _pickDayTime : _pickFullDateTime;

      final startLabel = startTime != null
          ? intl.DateFormat(dateFormat).format(startTime)
          : isSlotRecurring
              ? 'Day hh:mm'
              : 'dd/MMM/yy HH:mm';
      final endLabel = endTime != null
          ? intl.DateFormat(dateFormat).format(endTime)
          : isSlotRecurring
              ? 'Day hh:mm'
              : 'dd/MMM/yy HH:mm';

      final isStartSelected = startTime != null;
      final isEndSelected = endTime != null;

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppStyles.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Completion & Remove Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isCompleted,
                          onChanged: (newValue) =>
                              _toggleSlotCompletion(index, newValue),
                          activeColor: Colors.black,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        const Text('Check Slot',
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _removeSlot(index),
                      child: Row(
                        children: [
                          const Text('Remove Slot',
                              style: TextStyle(fontSize: 14)),
                          Icon(Icons.delete,
                              color: Colors.red[400], size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. Time Chips COLUMN
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeSlotChip(startLabel, isStartSelected,
                        onTap: () => pickFunction(index, 'start')),
                    const SizedBox(height: 10),
                    _buildTimeSlotChip(endLabel, isEndSelected,
                        onTap: () => pickFunction(index, 'end')),
                  ],
                ),
                const SizedBox(height: 10),

                // 3. Recurring Task Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isSlotRecurring,
                      onChanged: (newValue) =>
                          _toggleSlotRecurring(index, newValue ?? false),
                      activeColor: AppStyles.primaryPurple,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    const Text('Recurring Task',
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });

    children.addAll([
      const SizedBox(height: 5),
      Row(
        children: [
          const Text('Add slot', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: _addSlot,
            child: const Icon(Icons.add_circle_outline, color: Colors.black),
          ),
        ],
      ),
      const SizedBox(height: 15),
      Row(
        children: [
          const Text('Add Slot(s) Later', style: TextStyle(fontSize: 14)),
          Checkbox(value: false, onChanged: null, activeColor: Colors.black),
        ],
      ),
    ]);

    return _buildCardSection(children: children);
  }

  Widget _buildDifficultySection() {
    final hours = difficultyTime['hours']!.toString().padLeft(3, '0');
    final minutes = difficultyTime['minutes']!.toString().padLeft(2, '0');
    final difficultyTimeLabel = '$hours:$minutes';
    final bool isTimeSelected = selectedDifficultyPeriod == 'Time';

    return _buildCardSection(
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (index) {
              return Icon(
                index < difficultyStars ? Icons.star : Icons.star_border,
                color: Colors.yellow[700],
                size: 28,
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children: [
            _buildPeriodChip(
              'Total',
              (label) => setState(() => selectedDifficultyPeriod = label),
            ),
            _buildPeriodChip(
              'Per week',
              (label) => setState(() => selectedDifficultyPeriod = label),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  selectedDifficultyPeriod = 'Time';
                });
                _pickDifficultyTime();
              },
              child: _buildTimeSlotChip(difficultyTimeLabel, isTimeSelected),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildFriendsWorkSection(),
      ],
    );
  }

  Widget _buildFriendsWorkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Friends\' Work',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(width: 8),
            Icon(Icons.sentiment_satisfied_alt, size: 18, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock, color: AppStyles.primaryPurple),
              const SizedBox(width: 8),
              const Text('Friend Name',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 15),
              const Text('25%',
                  style: TextStyle(
                    color: AppStyles.primaryPurple,
                    fontWeight: FontWeight.bold,
                  )),
              Icon(Icons.scatter_plot,
                  color: AppStyles.primaryPurple, size: 18),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDoneButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Promise updated successfully!'),
                backgroundColor: AppStyles.successGreen,
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryPurple,
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Done ✓',
            style: TextStyle(
              color: AppStyles.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
