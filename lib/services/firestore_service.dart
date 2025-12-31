import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/promise_model.dart';
import '../models/user_model.dart';
import '../models/user_stats_model.dart';
import 'database_service.dart';

class FirestoreService implements DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- EXISTING PROMISE METHODS ---
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
    if (_userId == null) {
      throw Exception("User must be logged in to create a promise");
    }
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

  @override
  Stream<List<PromiseModel>> getPromisesStream() {
    if (_userId == null) return const Stream.empty();
    return _db
        .collection('promises')
        .where('createdBy', isEqualTo: _userId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PromiseModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> updatePromise(PromiseModel promise) async {
    if (_userId == null) {
      throw Exception("User must be logged in to update a promise");
    }
    await _db.collection('promises').doc(promise.id).update(promise.toMap());
  }

  @override
  Future<void> deletePromise(String promiseId) async {
    await _db.collection('promises').doc(promiseId).delete();
  }

  // --- NEW FRIEND METHODS ---

  @override
  Future<void> createPublicUser(
    String uid,
    String email,
    String displayName,
  ) async {
    // Create a searchable document
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'createdBy': uid, // <--- ADDED: Critical for Security Rules
      'email': email,
      'displayName': displayName,
      'searchEmail': email.toLowerCase(),
    }, SetOptions(merge: true));
  }

  @override
  Future<UserModel?> searchUserByEmail(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  @override
  Future<void> sendFriendRequest(
    String currentUid,
    String currentName,
    String currentEmail,
    String targetUid,
  ) async {
    // Add to target's "friend_requests" subcollection
    await _db
        .collection('users')
        .doc(targetUid)
        .collection('friend_requests')
        .doc(currentUid)
        .set({
          'uid': currentUid,
          'displayName': currentName,
          'email': currentEmail,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> acceptFriendRequest(
    String currentUid,
    String currentName,
    String currentEmail,
    String requestUid,
    String requestName,
    String requestEmail,
  ) async {
    final batch = _db.batch();

    // 1. Add B to A's friends
    final myFriendRef = _db
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(requestUid);
    batch.set(myFriendRef, {
      'uid': requestUid,
      'displayName': requestName,
      'email': requestEmail,
      'since': FieldValue.serverTimestamp(),
    });

    // 2. Add A to B's friends
    final theirFriendRef = _db
        .collection('users')
        .doc(requestUid)
        .collection('friends')
        .doc(currentUid);
    batch.set(theirFriendRef, {
      'uid': currentUid,
      'displayName': currentName,
      'email': currentEmail,
      'since': FieldValue.serverTimestamp(),
    });

    // 3. Delete the request
    final requestRef = _db
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .doc(requestUid);
    batch.delete(requestRef);

    await batch.commit();
  }

  @override
  Future<void> declineFriendRequest(
    String currentUid,
    String requestUid,
  ) async {
    await _db
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .doc(requestUid)
        .delete();
  }

  @override
  Stream<List<UserModel>> getFriendRequestsStream() {
    if (_userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_userId)
        .collection('friend_requests')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<UserModel>> getFriendsStream() {
    if (_userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_userId)
        .collection('friends')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // --- GAMIFICATION IMPLEMENTATION ---

  @override
  Stream<UserStatsModel> getUserStatsStream() {
    if (_userId == null) return const Stream.empty();

    // Listen to the 'stats' subcollection or a specific document for stats
    // We'll store stats in users/{uid}/gamification/stats
    return _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats')
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            // value if not exists
            return UserStatsModel();
          }
          return UserStatsModel.fromMap(doc.data()!);
        });
  }

  @override
  Future<void> updateUserStats(UserStatsModel stats) async {
    if (_userId == null) {
      throw Exception("User must be logged in to update stats");
    }
    await _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats')
        .set(stats.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateCoins(int amount) async {
    if (_userId == null) {
      throw Exception("User must be logged in to update coins");
    }

    final ref = _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats');

    // Use a transaction or FieldValue.increment for safety
    await ref.set({
      'coins': FieldValue.increment(amount),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> unlockItem(String itemId) async {
    if (_userId == null) return;

    final ref = _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats');

    await ref.set({
      'inventory': FieldValue.arrayUnion([itemId]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    if (_userId == null) return;

    final ref = _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats');

    await ref.set({
      'achievements': FieldValue.arrayUnion([achievementId]),
    }, SetOptions(merge: true));
  }
}
