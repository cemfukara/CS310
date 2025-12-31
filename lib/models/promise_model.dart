import 'package:cloud_firestore/cloud_firestore.dart';

class PromiseModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final int durationMinutes; // Changed from endTime to duration
  final bool isRecursive;
  final bool isCompleted;
  final String createdBy;
  final DateTime createdAt;
  final String category;
  final int priority;
  final String? sharedBy;

  PromiseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.durationMinutes,
    required this.isRecursive,
    this.isCompleted = false,
    required this.createdBy,
    required this.createdAt,
    this.category = 'General',
    this.priority = 1,
    this.sharedBy,
  });

  /// Helper to calculate endTime dynamically
  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  /// Factory constructor to create a PromiseModel from a Firestore Document
  factory PromiseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PromiseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] is Timestamp)
          ? (data['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      // Handle legacy data or new duration format
      durationMinutes: data['durationMinutes'] ?? 60,
      isRecursive: data['isRecursive'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      category: data['category'] ?? 'General',
      priority: data['priority'] ?? 1,
      sharedBy: data['sharedBy'],
    );
  }

  /// Convert PromiseModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes, // Save duration
      'isRecursive': isRecursive,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
      'priority': priority,
      'sharedBy': sharedBy,
    };
  }

  PromiseModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    int? durationMinutes,
    bool? isRecursive,
    bool? isCompleted,
    String? createdBy,
    DateTime? createdAt,
    String? category,
    int? priority,
    String? sharedBy,
  }) {
    return PromiseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isRecursive: isRecursive ?? this.isRecursive,
      isCompleted: isCompleted ?? this.isCompleted,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      sharedBy: sharedBy ?? this.sharedBy,
    );
  }
}
