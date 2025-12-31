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
  // --- STATE VARIABLES ---
  late PromiseModel _originalPromise;
  bool _isInit = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Difficulty Settings
  String selectedDifficultyPeriod = 'Total';
  int difficultyStars = 3;
  Map<String, int> difficultyTime = {'hours': 0, 'minutes': 0};

  // Slots
  List<Map<String, dynamic>> dynamicSlots = [];

  // Date Formats
  static const String fullDateTimeFormat = 'dd/MMM/yy HH:mm';
  static const String dayTimeFormat = 'EEE HH:mm';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // 1. RECEIVE DATA passed from Home Screen
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is PromiseModel) {
        _originalPromise = args;
        _initializeData(_originalPromise);
      }
      _isInit = true;
    }
  }

  void _initializeData(PromiseModel promise) {
    // 2. PRE-FILL FIELDS
    _nameController.text = promise.title;
    _descriptionController.text = promise.description;
    difficultyStars = promise.priority;

    // 3. INITIALIZE SLOTS with correct date (Fixes the "1 day later" bug)
    dynamicSlots = [
      {
        'start': promise.startTime,
        'end': promise.endTime,
        'completed': promise.isCompleted,
        'is_recurring': promise.isRecursive,
      },
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- SAVE LOGIC ---
  Future<void> _handleSaveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a promise name.")),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = Provider.of<PromiseProvider>(context, listen: false);

      // 1. UPDATE THE EXISTING PROMISE (Using the first slot)
      if (dynamicSlots.isNotEmpty) {
        final mainSlot = dynamicSlots[0];

        final updatedPromise = _originalPromise.copyWith(
          title: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          startTime: mainSlot['start'],
          endTime: mainSlot['end'],
          isRecursive: mainSlot['is_recurring'],
          isCompleted: mainSlot['completed'],
          priority: difficultyStars,
        );

        await provider.updatePromise(updatedPromise);
      }

      // 2. HANDLE EXTRA SLOTS (If user added more slots, create new promises for them)
      if (dynamicSlots.length > 1) {
        for (int i = 1; i < dynamicSlots.length; i++) {
          final slot = dynamicSlots[i];
          if (slot['start'] != null && slot['end'] != null) {
            await provider.addPromise(
              title: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              startTime: slot['start'],
              endTime: slot['end'],
              isRecursive: slot['is_recurring'],
              category: _originalPromise.category,
              priority: difficultyStars,
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close Loader
        Navigator.pop(context); // Go back to Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: AppStyles.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close Loader
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating: $e')));
      }
    }
  }

  // --- SLOT & UI METHODS ---

  void _addSlot() {
    setState(() {
      dynamicSlots.add({
        'start': DateTime.now(),
        'end': DateTime.now().add(const Duration(hours: 1)),
        'completed': false,
        'is_recurring': false,
      });
    });
  }

  void _removeSlot(int index) {
    if (dynamicSlots.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot remove the last slot.")),
      );
      return;
    }
    setState(() => dynamicSlots.removeAt(index));
  }

  Future<void> _pickFullDateTime(int index, String type) async {
    DateTime now = DateTime.now();
    DateTime? initialDateTime = dynamicSlots[index][type];
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

    setState(() {
      dynamicSlots[index][type] = finalDateTime;
    });
  }

  Widget _buildNameSection() {
    return _buildCardSection(
      children: [
        const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: _nameController),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return _buildCardSection(
      children: [
        const Text(
          "Description",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextField(controller: _descriptionController, maxLines: 3),
      ],
    );
  }

  Widget _buildSlotsSection() {
    List<Widget> children = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Time Slots",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            onPressed: _addSlot,
            icon: const Icon(Icons.add_circle, color: AppStyles.primaryPurple),
          ),
        ],
      ),
    ];

    for (int i = 0; i < dynamicSlots.length; i++) {
      final slot = dynamicSlots[i];
      final start = slot['start'] as DateTime?;
      final end = slot['end'] as DateTime?;

      final startText = start != null
          ? intl.DateFormat(fullDateTimeFormat).format(start)
          : "Select Start";
      final endText = end != null
          ? intl.DateFormat(fullDateTimeFormat).format(end)
          : "Select End";

      children.add(
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Slot ${i + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (i > 0)
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _removeSlot(i),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              ListTile(
                title: Text("Start: $startText"),
                trailing: const Icon(Icons.calendar_today, size: 16),
                dense: true,
                onTap: () => _pickFullDateTime(i, 'start'),
              ),
              ListTile(
                title: Text("End:   $endText"),
                trailing: const Icon(Icons.calendar_today, size: 16),
                dense: true,
                onTap: () => _pickFullDateTime(i, 'end'),
              ),
            ],
          ),
        ),
      );
    }
    return _buildCardSection(children: children);
  }

  Widget _buildCardSection({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDifficultySection() {
    return _buildCardSection(
      children: [
        const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < difficultyStars ? Icons.star : Icons.star_border,
                color: Colors.orange,
              ),
              onPressed: () => setState(() => difficultyStars = index + 1),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Promise'),
        backgroundColor: AppStyles.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNameSection(),
            _buildDescriptionSection(),
            _buildSlotsSection(),
            _buildDifficultySection(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _handleSaveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
