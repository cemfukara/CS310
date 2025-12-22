import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a single Promise/Commitment
class PromiseModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String category;
  final int priority; // 1 (low) to 5 (high)
  final bool isCompleted;

  // -- NEW FIELDS FOR FIRESTORE --
  final String createdBy; // User ID
  final DateTime createdAt; // Timestamp

  PromiseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.priority,
    this.isCompleted = false,
    required this.createdBy,
    required this.createdAt,
  });

  /// Factory constructor to create a PromiseModel from a Firestore Document
  factory PromiseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PromiseModel(
      id: doc.id, // We use the Document ID from Firestore as our Model ID
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      // Handle Firestore Timestamp conversion safely
      dueDate: (data['dueDate'] is Timestamp)
          ? (data['dueDate'] as Timestamp).toDate()
          : DateTime.now(),
      category: data['category'] ?? 'General',
      priority: data['priority'] ?? 1,
      isCompleted: data['isCompleted'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert PromiseModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      // Convert DateTime to Timestamp for Firestore
      'dueDate': Timestamp.fromDate(dueDate),
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy of the PromiseModel with updated fields
  PromiseModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    int? priority,
    bool? isCompleted,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return PromiseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PromiseModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              description == other.description &&
              dueDate == other.dueDate &&
              category == other.category &&
              priority == other.priority &&
              isCompleted == other.isCompleted &&
              createdBy == other.createdBy &&
              createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      category.hashCode ^
      priority.hashCode ^
      isCompleted.hashCode ^
      createdBy.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'PromiseModel(id: $id, title: $title, status: $isCompleted, user: $createdBy)';
  }

  /// Get dummy/sample promises for testing and display purposes
  static List<PromiseModel> getSamplePromises() {
    final now = DateTime.now();
    return [
      PromiseModel(
        id: '1',
        title: 'Complete Project Report',
        description: 'Finish the quarterly project report',
        dueDate: now,
        category: 'Work',
        priority: 5,
        isCompleted: false,
        createdBy: 'test_user',
        createdAt: now,
      ),
      PromiseModel(
        id: '2',
        title: 'Call Mom',
        description: 'Call mom to check how she is doing',
        dueDate: now,
        category: 'Personal',
        priority: 4,
        isCompleted: false,
        createdBy: 'test_user',
        createdAt: now,
      ),
      PromiseModel(
        id: '3',
        title: 'Gym Session',
        description: 'Hit the gym for 1 hour',
        dueDate: now,
        category: 'Health',
        priority: 3,
        isCompleted: false,
        createdBy: 'test_user',
        createdAt: now,
      ),
    ];
  }
}