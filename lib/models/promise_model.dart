import 'package:cloud_firestore/cloud_firestore.dart';

class PromiseModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final int durationMinutes;
  final bool isRecursive;
  // REMOVED: final bool isCompleted;
  // ADDED: List of UIDs who completed this promise (for non-recursive)
  final List<String> completedBy;
  final String createdBy;
  final DateTime createdAt;
  final String category;
  final int priority;
  final String? sharedBy;
  final List<String> participants;
  final List<String> pendingParticipants;
  // UPDATED: Now stores strings in format "yyyy-MM-dd_uid" for recursive
  final List<String> completedDates;

  PromiseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.durationMinutes,
    required this.isRecursive,
    this.completedBy = const [], // Default empty
    required this.createdBy,
    required this.createdAt,
    this.category = 'General',
    this.priority = 1,
    this.sharedBy,
    this.participants = const [],
    this.pendingParticipants = const [],
    this.completedDates = const [],
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  // --- HELPER TO CHECK STATUS FOR SPECIFIC USER ---
  bool isCompletedForUser(String uid, {DateTime? date}) {
    if (isRecursive) {
      if (date == null) return false;
      // Check for specific date + uid tag
      final tag =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}_$uid";
      return completedDates.contains(tag);
    } else {
      // Check if uid is in the completedBy list
      return completedBy.contains(uid);
    }
  }

  factory PromiseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PromiseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] is Timestamp)
          ? (data['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      durationMinutes: data['durationMinutes'] ?? 60,
      isRecursive: data['isRecursive'] ?? false,
      // Load completedBy list
      completedBy: List<String>.from(data['completedBy'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      category: data['category'] ?? 'General',
      priority: data['priority'] ?? 1,
      sharedBy: data['sharedBy'],
      participants: List<String>.from(data['participants'] ?? []),
      pendingParticipants: List<String>.from(data['pendingParticipants'] ?? []),
      completedDates: List<String>.from(data['completedDates'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'isRecursive': isRecursive,
      'completedBy': completedBy, // Persist list
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
      'priority': priority,
      'sharedBy': sharedBy,
      'participants': participants,
      'pendingParticipants': pendingParticipants,
      'completedDates': completedDates,
    };
  }

  PromiseModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    int? durationMinutes,
    bool? isRecursive,
    List<String>? completedBy,
    String? createdBy,
    DateTime? createdAt,
    String? category,
    int? priority,
    String? sharedBy,
    List<String>? participants,
    List<String>? pendingParticipants,
    List<String>? completedDates,
  }) {
    return PromiseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isRecursive: isRecursive ?? this.isRecursive,
      completedBy: completedBy ?? this.completedBy,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      sharedBy: sharedBy ?? this.sharedBy,
      participants: participants ?? this.participants,
      pendingParticipants: pendingParticipants ?? this.pendingParticipants,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}