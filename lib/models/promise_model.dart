import 'package:cloud_firestore/cloud_firestore.dart';

class PromiseModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime; // New Field
  final DateTime endTime; // New Field
  final bool isRecursive; // New Field
  final bool isCompleted;
  final String createdBy;
  final DateTime createdAt;
  final String category;
  final int priority;

  PromiseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.isRecursive,
    this.isCompleted = false,
    required this.createdBy,
    required this.createdAt,
    this.category = 'General',
    this.priority = 1,
  });

  /// Factory constructor to create a PromiseModel from a Firestore Document
  factory PromiseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PromiseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      // Safe conversion for Timestamps
      startTime: (data['startTime'] is Timestamp)
          ? (data['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: (data['endTime'] is Timestamp)
          ? (data['endTime'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(hours: 1)),
      isRecursive: data['isRecursive'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      category: data['category'] ?? 'General',
      priority: data['priority'] ?? 1,
    );
  }

  /// Convert PromiseModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isRecursive': isRecursive,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
      'priority': priority,
    };
  }

  /// CopyWith method - REQUIRED for toggleStatus to work
  PromiseModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isRecursive,
    bool? isCompleted,
    String? createdBy,
    DateTime? createdAt,
    String? category,
    int? priority,
  }) {
    return PromiseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isRecursive: isRecursive ?? this.isRecursive,
      isCompleted: isCompleted ?? this.isCompleted,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }
}
