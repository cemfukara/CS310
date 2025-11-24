/// Data model representing a single Promise/Commitment
class PromiseModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String category;
  final int priority; // 1 (low) to 5 (high)
  final bool isCompleted;

  PromiseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.priority,
    this.isCompleted = false,
  });

  /// Factory constructor to create a PromiseModel from a JSON map
  factory PromiseModel.fromJson(Map<String, dynamic> json) {
    return PromiseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      category: json['category'] as String,
      priority: json['priority'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Convert PromiseModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
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
  }) {
    return PromiseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
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
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      category.hashCode ^
      priority.hashCode ^
      isCompleted.hashCode;

  @override
  String toString() {
    return 'PromiseModel(id: $id, title: $title, dueDate: $dueDate, priority: $priority, isCompleted: $isCompleted)';
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
      ),
      PromiseModel(
        id: '2',
        title: 'Call Mom',
        description: 'Call mom to check how she is doing',
        dueDate: now,
        category: 'Personal',
        priority: 4,
        isCompleted: false,
      ),
      PromiseModel(
        id: '3',
        title: 'Gym Session',
        description: 'Hit the gym for 1 hour',
        dueDate: now,
        category: 'Health',
        priority: 3,
        isCompleted: false,
      ),
      PromiseModel(
        id: '4',
        title: 'Review Code',
        description: 'Review pull requests from team members',
        dueDate: now,
        category: 'Work',
        priority: 4,
        isCompleted: false,
      ),
      PromiseModel(
        id: '5',
        title: 'Prepare Presentation',
        description: 'Prepare slides for tomorrow\'s meeting',
        dueDate: now.add(const Duration(days: 1)),
        category: 'Work',
        priority: 5,
        isCompleted: false,
      ),
    ];
  }
}
