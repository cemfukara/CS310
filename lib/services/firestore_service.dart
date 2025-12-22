import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/promise_model.dart';
import 'database_service.dart';

class FirestoreService implements DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<void> createPromise({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isRecursive,
    required String category,
    required int priority,
  }) async {
    if (_userId == null) return;

    await _db.collection('promises').add({
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isRecursive': isRecursive,
      'isCompleted': false,
      'createdBy': _userId,
      'createdAt': FieldValue.serverTimestamp(),
      'category': category,
      'priority': priority,
    });
  }

  // ... (getPromisesStream, updatePromise, deletePromise remain largely the same,
  // just ensure they use PromiseModel.fromFirestore)

  @override
  Stream<List<PromiseModel>> getPromisesStream() {
    if (_userId == null) return const Stream.empty();

    return _db.collection('promises')
        .where('createdBy', isEqualTo: _userId)
        .orderBy('startTime', descending: false) // Order by Start Time now
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PromiseModel.fromFirestore(doc)).toList());
  }

  // Include updatePromise and deletePromise implementations here...
  @override
  Future<void> updatePromise(PromiseModel promise) async {
    if (_userId == null) return;
    await _db.collection('promises').doc(promise.id).update(promise.toMap());
  }

  @override
  Future<void> deletePromise(String promiseId) async {
    await _db.collection('promises').doc(promiseId).delete();
  }
}