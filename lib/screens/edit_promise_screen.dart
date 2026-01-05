import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../models/promise_model.dart';
import '../models/user_model.dart';
import '../models/promise_request_model.dart';
import '../providers/promise_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/friends_provider.dart';
import '../services/database_service.dart';

class EditPromiseScreen extends StatefulWidget {
  const EditPromiseScreen({super.key});

  @override
  State<EditPromiseScreen> createState() => _EditPromiseScreenState();
}

class _EditPromiseScreenState extends State<EditPromiseScreen> {
  late PromiseModel _originalPromise;
  bool _isInit = false;
  bool _canEdit = true; // Permission flag

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int difficultyStars = 3;
  static const String fullDateTimeFormat = 'dd/MMM/yy HH:mm';

  String _selectedCategory = 'Personal';
  final List<String> _categories = ['Work', 'Personal', 'Health', 'Family'];

  List<Map<String, dynamic>> dynamicSlots = [];

  // Track newly selected friends to share with
  final List<String> _selectedFriendUids = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is PromiseModel) {
        _originalPromise = args;

        // --- CHECK PERMISSIONS ---
        // Only the creator (uid matches createdBy) can edit.
        final currentUser = Provider.of<AuthProvider>(
          context,
          listen: false,
        ).user;
        if (currentUser != null) {
          _canEdit = _originalPromise.createdBy == currentUser.uid;
        }

        _initializeData(_originalPromise);
      }
      _isInit = true;
    }
  }

  void _initializeData(PromiseModel promise) {
    _nameController.text = promise.title;
    _descriptionController.text = promise.description;
    difficultyStars = promise.priority;

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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppStyles.errorRed),
    );
  }

  Future<void> _handleSaveChanges() async {
    // Security check
    if (!_canEdit) return;
    if (_nameController.text.trim().isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = Provider.of<PromiseProvider>(context, listen: false);

      // 1. UPDATE EXISTING PROMISE
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
          category: _selectedCategory,
          priority: difficultyStars,
        );

        await provider.updatePromise(updatedPromise);
      }

      // 2. SEND NEW SHARE REQUESTS
      if (_selectedFriendUids.isNotEmpty) {
        await _shareWithFriends();
      }

      // 3. CREATE NEW PROMISES (If added via "Add Slot")
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
              category: _selectedCategory,
              priority: difficultyStars,
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close Loader
        Navigator.pop(context); // Close Screen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Changes saved!')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _shareWithFriends() async {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;

    if (currentUser == null) return;

    final mainSlot = dynamicSlots[0];
    final DateTime start = mainSlot['start'];
    final durMap = mainSlot['duration'] as Map<String, int>;
    final totalMinutes = (durMap['hours']! * 60) + durMap['minutes']!;
    final DateTime end = start.add(Duration(minutes: totalMinutes));

    for (String friendUid in _selectedFriendUids) {
      final request = PromiseRequestModel(
        id: '',
        senderUid: currentUser.uid,
        senderName: currentUser.displayName ?? 'Friend',
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: start,
        endTime: end,
        category: _selectedCategory,
        priority: difficultyStars,
        sentAt: DateTime.now(),
        linkedPromiseId: _originalPromise.id,
      );

      await db.sendPromiseRequest(friendUid, request);
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
    if (!_canEdit) return;

    final DateTime now = DateTime.now();

    DateTime initialDate = dynamicSlots[index]['start'] ?? now;
    if (initialDate.isBefore(now)) {
      initialDate = now;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    final bool isToday =
        pickedDate.year == now.year &&
            pickedDate.month == now.month &&
            pickedDate.day == now.day;

    if (isToday) {
      final DateTime pickedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (pickedDateTime.isBefore(now)) {
        _showErrorSnackbar(
          "Invalid time. Please select a time after "
              "${TimeOfDay.fromDateTime(now).format(context)}.",
        );
        return;
      }
    }

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
    if (!_canEdit) return;

    final currentDuration = dynamicSlots[index]['duration'] as Map<String, int>;
    TextEditingController hCtrl = TextEditingController(
      text: currentDuration['hours'].toString(),
    );
    TextEditingController mCtrl = TextEditingController(
      text: currentDuration['minutes'].toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Duration'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: hCtrl,
                decoration: const InputDecoration(labelText: 'Hrs'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: mCtrl,
                decoration: const InputDecoration(labelText: 'Mins'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Set'),
          ),
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

  Widget _buildFriendsSection(BuildContext context) {
    if (!_canEdit) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Share with Friends',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: StreamBuilder<List<UserModel>>(
            stream:
            Provider.of<FriendsProvider>(context, listen: false)
                .friendsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final friends = snapshot.data ?? [];

              if (friends.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "You haven't added any friends yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: [
                  ...friends.map((friend) {
                    final bool alreadyShared = _originalPromise.participants
                        .contains(friend.uid);
                    final bool isPending = _originalPromise.pendingParticipants
                        .contains(friend.uid);
                    final bool isSelected = _selectedFriendUids.contains(
                      friend.uid,
                    );

                    // Logic to disable
                    final bool isDisabled = alreadyShared || isPending;
                    final bool isChecked =
                        alreadyShared || isPending || isSelected;

                    // Text for status
                    String subtitleText = friend.email;
                    if (alreadyShared) {
                      subtitleText = "Already Shared";
                    } else if (isPending) {
                      subtitleText = "Request Pending";
                    }

                    return CheckboxListTile(
                      title: Text(friend.displayName),
                      subtitle: Text(
                        subtitleText,
                        style: TextStyle(
                          color: isPending
                              ? AppStyles.warningOrange
                              : (alreadyShared ? AppStyles.successGreen : null),
                        ),
                      ),
                      value: isChecked,
                      activeColor: AppStyles.primaryPurple,
                      onChanged: isDisabled
                          ? null
                          : (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedFriendUids.add(friend.uid);
                          } else {
                            _selectedFriendUids.remove(friend.uid);
                          }
                        });
                      },
                    );
                  }),
                ],
              );
            },
          ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- READ ONLY BANNER ---
            if (!_canEdit)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You can view this shared promise, but only the creator can edit details.",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              enabled: _canEdit,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              enabled: _canEdit,
            ),
            const SizedBox(height: 10),

            // --- CATEGORY SELECTOR ---
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: _categories.map((c) {
                  return ChoiceChip(
                    label: Text(c),
                    selected: _selectedCategory == c,
                    onSelected: _canEdit
                        ? (val) {
                      if (val) setState(() => _selectedCategory = c);
                    }
                        : null,
                    selectedColor: AppStyles.primaryPurple,
                    labelStyle: TextStyle(
                      color: _selectedCategory == c
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // --- SLOTS ---
            ...List.generate(dynamicSlots.length, (index) {
              final slot = dynamicSlots[index];
              final start = slot['start'] as DateTime?;
              final dur = slot['duration'] as Map<String, int>;

              return Card(
                child: ListTile(
                  title: Text(
                    start != null
                        ? intl.DateFormat(fullDateTimeFormat).format(start)
                        : 'No Date',
                  ),
                  subtitle: Text(
                    'Duration: ${dur['hours']}h ${dur['minutes']}m',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_canEdit) ...[
                        IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () => _pickStartDate(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.timer),
                          onPressed: () => _pickDuration(index),
                        ),
                        if (index > 0)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSlot(index),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            // --- ACTION BUTTONS ---
            if (_canEdit && dynamicSlots.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Slot'),
                onPressed: _addSlot,
              ),

            const SizedBox(height: 10),

            // --- FRIENDS SECTION ---
            _buildFriendsSection(context),

            const SizedBox(height: 20),

            if (_canEdit)
              ElevatedButton(
                onPressed: _handleSaveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryPurple,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}