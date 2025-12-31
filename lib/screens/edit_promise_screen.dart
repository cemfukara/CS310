import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../models/promise_model.dart';
import '../providers/promise_provider.dart';

class EditPromiseScreen extends StatefulWidget {
  const EditPromiseScreen({super.key});

  @override
  State<EditPromiseScreen> createState() => _EditPromiseScreenState();
}

class _EditPromiseScreenState extends State<EditPromiseScreen> {
  late PromiseModel _originalPromise;
  bool _isInit = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startTime;
  DateTime? _endTime;
  bool _isRecursive = false;
  int _priority = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as PromiseModel;
      _originalPromise = args;
      _nameController.text = args.title;
      _descriptionController.text = args.description;
      _startTime = args.startTime;
      _endTime = args.endTime;
      _isRecursive = args.isRecursive;
      _priority = args.priority;
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initial = isStart ? _startTime! : _endTime!;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (time == null) return;

    setState(() {
      final newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (isStart) {
        _startTime = newDateTime;
      } else {
        _endTime = newDateTime;
      }
    });
  }

  // --- SAVE CHANGES (UPDATED) ---
  void _handleSaveChanges() async {
    if (_nameController.text.isEmpty) return;

    if (_endTime!.isBefore(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time cannot be before start time')),
      );
      return;
    }

    // 1. Create Updated Model using copyWith
    final updatedPromise = _originalPromise.copyWith(
      title: _nameController.text,
      description: _descriptionController.text,
      startTime: _startTime,
      endTime: _endTime,
      isRecursive: _isRecursive,
      priority: _priority,
    );

    // 2. Call Provider
    try {
      await Provider.of<PromiseProvider>(
        context,
        listen: false,
      ).updatePromise(updatedPromise);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating promise: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = intl.DateFormat('dd/MMM/yy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Promise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Promise?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await Provider.of<PromiseProvider>(
                  context,
                  listen: false,
                ).deletePromise(_originalPromise.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text("Start Time"),
              subtitle: Text(dateFormat.format(_startTime!)),
              trailing: const Icon(Icons.edit),
              onTap: () => _pickDateTime(true),
            ),
            ListTile(
              title: const Text("End Time"),
              subtitle: Text(dateFormat.format(_endTime!)),
              trailing: const Icon(Icons.edit),
              onTap: () => _pickDateTime(false),
            ),
            SwitchListTile(
              title: const Text("Recurring"),
              value: _isRecursive,
              onChanged: (val) => setState(() => _isRecursive = val),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSaveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
