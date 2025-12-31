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

  // --- PROMISE METHODS ---
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
    // --- FIX: Null Check ---
    final uid = _userId;
    if (uid == null) {
      throw Exception("User must be logged in to create a promise");
    }

    await _db.collection('promises').add({
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isRecursive': isRecursive,
      'isCompleted': false,
      'createdBy': uid, // Safe to use now
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
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PromiseModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> updatePromise(PromiseModel promise) async {
    await _db.collection('promises').doc(promise.id).update(promise.toMap());
  }

  @override
  Future<void> deletePromise(String promiseId) async {
    await _db.collection('promises').doc(promiseId).delete();
  }

  // --- FRIEND METHODS ---
  @override
  Future<void> createPublicUser(
    String uid,
    String email,
    String displayName,
  ) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'searchKey': email.toLowerCase(),
    }, SetOptions(merge: true));
  }

  @override
  Future<UserModel?> searchUserByEmail(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('searchKey', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<void> sendFriendRequest(
    String currentUid,
    String currentName,
    String currentEmail,
    String targetUid,
  ) async {
    // Add to Target's 'friendRequests' subcollection
    await _db
        .collection('users')
        .doc(targetUid)
        .collection('friendRequests')
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

    // 1. Add to Current User's friends
    final myFriendRef = _db
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(requestUid);
    batch.set(myFriendRef, {
      'uid': requestUid,
      'displayName': requestName,
      'email': requestEmail,
    });

    // 2. Add to Other User's friends
    final otherFriendRef = _db
        .collection('users')
        .doc(requestUid)
        .collection('friends')
        .doc(currentUid);
    batch.set(otherFriendRef, {
      'uid': currentUid,
      'displayName': currentName,
      'email': currentEmail,
    });

    // 3. Remove request
    final requestRef = _db
        .collection('users')
        .doc(currentUid)
        .collection('friendRequests')
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
        .collection('friendRequests')
        .doc(requestUid)
        .delete();
  }

  @override
  Stream<List<UserModel>> getFriendRequestsStream() {
    if (_userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_userId)
        .collection('friendRequests')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => UserModel.fromMap(doc.data())).toList(),
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
          (snap) =>
              snap.docs.map((doc) => UserModel.fromMap(doc.data())).toList(),
        );
  }

  // --- GAMIFICATION METHODS ---
  @override
  Stream<UserStatsModel> getUserStatsStream() {
    if (_userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return UserStatsModel();
          return UserStatsModel.fromMap(doc.data()!);
        });
  }

  @override
  Future<void> updateUserStats(UserStatsModel stats) async {
    if (_userId == null) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats')
        .set(stats.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateCoins(int amount) async {
    if (_userId == null) return;
    final ref = _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats');

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
