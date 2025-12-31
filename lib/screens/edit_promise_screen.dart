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

  int difficultyStars = 3;
  static const String fullDateTimeFormat = 'dd/MMM/yy HH:mm';

  // --- CATEGORY STATE ---
  String _selectedCategory = 'Personal';
  final List<String> _categories = ['Work', 'Personal', 'Health', 'Family'];

  List<Map<String, dynamic>> dynamicSlots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is PromiseModel) {
        _originalPromise = args;
        _initializeData(_originalPromise);
      }
      _isInit = true;
    }
  }

  void _initializeData(PromiseModel promise) {
    _nameController.text = promise.title;
    _descriptionController.text = promise.description;
    difficultyStars = promise.priority;

    // Initialize Category (fallback to Personal if not in list)
    if (_categories.contains(promise.category)) {
      _selectedCategory = promise.category;
    } else {
      _selectedCategory = 'Personal';
    }

    int hours = promise.durationMinutes ~/ 60;
    int minutes = promise.durationMinutes % 60;

    dynamicSlots = [
      {
        'start': promise.startTime,
        'duration': {'hours': hours, 'minutes': minutes},
        'completed': promise.isCompleted,
        'is_recurring': promise.isRecursive,
      },
    ];
  }

  Future<void> _handleSaveChanges() async {
    if (_nameController.text.trim().isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = Provider.of<PromiseProvider>(context, listen: false);

      // 1. UPDATE EXISTING
      if (dynamicSlots.isNotEmpty) {
        final mainSlot = dynamicSlots[0];
        final durMap = mainSlot['duration'] as Map<String, int>;
        final totalMinutes = (durMap['hours']! * 60) + durMap['minutes']!;

        final updatedPromise = _originalPromise.copyWith(
          title: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          startTime: mainSlot['start'],
          durationMinutes: totalMinutes,
          isRecursive: mainSlot['is_recurring'],
          isCompleted: mainSlot['completed'],
          category: _selectedCategory, // --- UPDATE CATEGORY ---
          priority: difficultyStars,
        );

        await provider.updatePromise(updatedPromise);
      }

      // 2. ADD EXTRA SLOTS (as new promises)
      if (dynamicSlots.length > 1) {
        for (int i = 1; i < dynamicSlots.length; i++) {
          final slot = dynamicSlots[i];
          if (slot['start'] != null) {
            final durMap = slot['duration'] as Map<String, int>;
            final totalMinutes = (durMap['hours']! * 60) + durMap['minutes']!;

            await provider.addPromise(
              title: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              startTime: slot['start'],
              durationMinutes: totalMinutes,
              isRecursive: slot['is_recurring'] ?? false,
              category: _selectedCategory, // --- USE NEW CATEGORY ---
              priority: difficultyStars,
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close Loader
        Navigator.pop(context); // Go back
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved!')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _addSlot() {
    setState(() {
      dynamicSlots.add({
        'start': DateTime.now(),
        'duration': {'hours': 1, 'minutes': 0},
        'completed': false,
        'is_recurring': false,
      });
    });
  }

  void _removeSlot(int index) {
    if (dynamicSlots.length <= 1) return;
    setState(() => dynamicSlots.removeAt(index));
  }

  Future<void> _pickStartDate(int index) async {
    DateTime now = DateTime.now();
    DateTime? initialDate = dynamicSlots[index]['start'];
    initialDate ??= now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (pickedTime == null) return;

    setState(() {
      dynamicSlots[index]['start'] = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _pickDuration(int index) async {
    final currentDuration = dynamicSlots[index]['duration'] as Map<String, int>;
    TextEditingController hCtrl = TextEditingController(text: currentDuration['hours'].toString());
    TextEditingController mCtrl = TextEditingController(text: currentDuration['minutes'].toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Duration'),
        content: Row(
          children: [
            Expanded(child: TextField(controller: hCtrl, decoration: const InputDecoration(labelText: 'Hrs'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: mCtrl, decoration: const InputDecoration(labelText: 'Mins'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Set')),
        ],
      ),
    ).then((_) {
      int h = int.tryParse(hCtrl.text) ?? 0;
      int m = int.tryParse(mCtrl.text) ?? 0;
      setState(() {
        dynamicSlots[index]['duration'] = {'hours': h, 'minutes': m};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Promise'), backgroundColor: AppStyles.primaryPurple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 10),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            const SizedBox(height: 10),

            // --- CATEGORY SELECTOR IN EDIT MODE ---
            Align(alignment: Alignment.centerLeft, child: Text("Category", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: _categories.map((c) {
                  return ChoiceChip(
                    label: Text(c),
                    selected: _selectedCategory == c,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = c);
                    },
                    selectedColor: AppStyles.primaryPurple,
                    labelStyle: TextStyle(color: _selectedCategory == c ? Colors.white : Colors.black),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            ...List.generate(dynamicSlots.length, (index) {
              final slot = dynamicSlots[index];
              final start = slot['start'] as DateTime?;
              final dur = slot['duration'] as Map<String, int>;

              return Card(
                child: ListTile(
                  title: Text(start != null ? intl.DateFormat(fullDateTimeFormat).format(start) : 'No Date'),
                  subtitle: Text('Duration: ${dur['hours']}h ${dur['minutes']}m'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_calendar), onPressed: () => _pickStartDate(index)),
                      IconButton(icon: const Icon(Icons.timer), onPressed: () => _pickDuration(index)),
                      if (index > 0) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeSlot(index)),
                    ],
                  ),
                ),
              );
            }),
            if (dynamicSlots.isNotEmpty)
              TextButton.icon(icon: const Icon(Icons.add), label: const Text('Add Slot'), onPressed: _addSlot),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSaveChanges,
              style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryPurple, minimumSize: const Size(double.infinity, 50)),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}