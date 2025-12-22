import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/promise_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userId;

  DatabaseService({this.userId});

  // Collection Reference
  CollectionReference get _promisesCollection => _db.collection('promises');

  // 1. CREATE: Add a new promise
  Future<void> addPromise(PromiseModel promise) async {
    if (userId == null) return;

    // We create a document with an auto-generated ID first if needed,
    // but better to let Firestore generate it or use the one from the model if set.
    // Here we let Firestore generate a unique ID.
    DocumentReference docRef = _promisesCollection.doc();

    // Create the data object ensuring we link it to the user
    final data = promise.copyWith(id: docRef.id).toJson();
    data['createdBy'] = userId; // Requirement: CreatedBy field [cite: 28]
    data['createdAt'] = FieldValue.serverTimestamp(); // Requirement: CreatedAt timestamp [cite: 29]

    await docRef.set(data);
  }

  // 2. READ: Stream of promises for the current user
  Stream<List<PromiseModel>> get promises {
    if (userId == null) return Stream.value([]);

    return _promisesCollection
        .where('createdBy', isEqualTo: userId) // Security: Only get own data [cite: 34]
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_promiseListFromSnapshot);
  }

  // Helper: Convert Firestore snapshot to List<PromiseModel>
  List<PromiseModel> _promiseListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Handle the Timestamp conversion from Firestore
      // Firestore returns Timestamp, but our model expects String (ISO8601) or DateTime
      // We need to ensure we pass a compatible map to PromiseModel.fromJson
      if (data['dueDate'] is Timestamp) {
        data['dueDate'] = (data['dueDate'] as Timestamp).toDate().toIso8601String();
      }

      return PromiseModel.fromJson(data);
    }).toList();
  }

  // 3. UPDATE: Update an existing promise
  Future<void> updatePromise(PromiseModel promise) async {
    if (userId == null) return;

    // Convert to JSON but remove the ID (not needed in the body) and createdBy
    final data = promise.toJson();
    data.remove('id');
    data.remove('createdBy'); // Should not change

    // Ensure dueDate is stored as a string or Timestamp consistent with your DB preference
    // (Here we keep it simple with the toJson output which is string)

    await _promisesCollection.doc(promise.id).update(data);
  }

  // 4. DELETE: Remove a promise
  Future<void> deletePromise(String promiseId) async {
    if (userId == null) return;
    await _promisesCollection.doc(promiseId).delete();
  }

  // Toggle Completion Status (Quick Update)
  Future<void> togglePromiseStatus(String promiseId, bool currentStatus) async {
    if (userId == null) return;
    await _promisesCollection.doc(promiseId).update({
      'isCompleted': !currentStatus,
    });
  }
}