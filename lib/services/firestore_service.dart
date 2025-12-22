import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/promise_model.dart';
import 'database_service.dart';

class FirestoreService implements DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the current logged-in user's ID
  String? get _userId => _auth.currentUser?.uid;

  // Collection Reference (DRY - Don't Repeat Yourself)
  CollectionReference get _promisesCollection => _db.collection('promises');

  @override
  Future<void> createPromise({
    required String title,
    required String description,
    required DateTime dueDate,
    required String category,
    required int priority,
  }) async {
    if (_userId == null) throw Exception("User must be logged in to create a promise");

    // We don't create a PromiseModel here yet because we don't have an ID.
    // We send the Map directly to Firestore.
    await _promisesCollection.add({
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate), // Convert DateTime to Timestamp
      'category': category,
      'priority': priority,
      'isCompleted': false,
      'createdBy': _userId, // Automatically link to current user
      'createdAt': FieldValue.serverTimestamp(), // Server-side time
    });
  }

  @override
  Stream<List<PromiseModel>> getPromisesStream() {
    if (_userId == null) return const Stream.empty();

    return _promisesCollection
        .where('createdBy', isEqualTo: _userId) // Security: Only show my data
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // use the fromFirestore factory we created
        return PromiseModel.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Future<void> updatePromise(PromiseModel promise) async {
    if (_userId == null) return;

    // We use .toMap() here to convert our object back to data Firestore understands
    // We do NOT update 'createdBy' or 'createdAt' to preserve history
    await _promisesCollection.doc(promise.id).update(promise.toMap());
  }

  // Specific helper to toggle status quickly (optional but useful)
  Future<void> toggleStatus(String promiseId, bool currentStatus) async {
    await _promisesCollection.doc(promiseId).update({
      'isCompleted': !currentStatus,
    });
  }

  @override
  Future<void> deletePromise(String promiseId) async {
    if (_userId == null) return;
    await _promisesCollection.doc(promiseId).delete();
  }
}