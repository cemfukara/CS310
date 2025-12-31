import 'package:cloud_firestore/cloud_firestore.dart';

class PromiseRequestModel {
  final String id;
  final String senderUid;
  final String senderName;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final int priority;
  final DateTime sentAt;

  PromiseRequestModel({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.priority,
    required this.sentAt,
  });

  factory PromiseRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PromiseRequestModel(
      id: doc.id,
      senderUid: data['senderUid'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      category: data['category'] ?? 'General',
      priority: data['priority'] ?? 3,
      sentAt: (data['sentAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'senderName': senderName,
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'category': category,
      'priority': priority,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }
}