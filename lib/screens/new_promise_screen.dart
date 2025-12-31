import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../models/promise_model.dart';
import '../providers/promise_provider.dart';
import '../providers/auth_provider.dart';

class NewPromiseScreen extends StatefulWidget {
  const NewPromiseScreen({super.key});

  @override
  State<NewPromiseScreen> createState() => _NewPromiseScreenState();
}

class _NewPromiseScreenState extends State<NewPromiseScreen> {
  // --- DATE FORMAT CONSTANTS ---
  static const String fullDateTimeFormat = 'dd/MMM/yy HH:mm';
  static const String dayTimeFormat = 'EEE HH:mm';

  // --- STATE VARIABLES ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isRecurring = false;

  // Difficulty / Priority
  String selectedDifficultyPeriod = 'Total';
  int difficultyStars = 1; // 1 to 5 stars (Priority)

  // Dates
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- DATE PICKERS ---
  Future<void> _pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      if (isStart) {
        _startDate = date;
        _startTime = time;
      } else {
        _endDate = date;
        _endTime = time;
      }
    });
  }

  // --- SAVE FUNCTION (UPDATED) ---
  void _handleCreatePromise() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a promise name')),
      );
      return;
    }

    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end times')),
      );
      return;
    }

    // Combine Date + Time
    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    // Get current user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.user?.uid ?? '';

    // 1. Create the Model Object
    final newPromise = PromiseModel(
      id: '', // DB will assign ID
      title: _nameController.text,
      description: _descriptionController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      isRecursive: isRecurring,
      createdBy: uid,
      createdAt: DateTime.now(),
      category: 'General', // Default or add a picker
      priority: difficultyStars,
    );

    // 2. Pass Model to Provider
    try {
      await Provider.of<PromiseProvider>(
        context,
        listen: false,
      ).createPromise(newPromise);

      if (mounted) {
        Navigator.pop(context); // Close screen on success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating promise: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standard Date Formatters
    final dateFormat = intl.DateFormat(fullDateTimeFormat);

    return Scaffold(
      appBar: AppBar(title: const Text('New Promise')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Promise Name',
                hintText: 'e.g. Morning Jog',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Dates
            Text('Time & Duration', style: AppStyles.headingSmall),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(
                _startDate != null && _startTime != null
                    ? dateFormat.format(
                        DateTime(
                          _startDate!.year,
                          _startDate!.month,
                          _startDate!.day,
                          _startTime!.hour,
                          _startTime!.minute,
                        ),
                      )
                    : 'Select Start Time',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDateTime(true),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(
                _endDate != null && _endTime != null
                    ? dateFormat.format(
                        DateTime(
                          _endDate!.year,
                          _endDate!.month,
                          _endDate!.day,
                          _endTime!.hour,
                          _endTime!.minute,
                        ),
                      )
                    : 'Select End Time',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDateTime(false),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 20),

            // Recurring
            SwitchListTile(
              title: const Text('Recurring Event?'),
              value: isRecurring,
              onChanged: (val) => setState(() => isRecurring = val),
            ),

            const SizedBox(height: 20),

            // Priority / Stars
            Text('Priority (Stars)', style: AppStyles.headingSmall),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < difficultyStars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => difficultyStars = index + 1),
                );
              }),
            ),

            const SizedBox(height: 30),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleCreatePromise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Create Promise',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
