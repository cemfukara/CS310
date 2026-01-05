import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/promise_model.dart';
import '../models/user_model.dart';
import '../models/user_stats_model.dart';
import '../models/promise_request_model.dart';
import 'database_service.dart';

class FirestoreService implements DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- PROMISE METHODS ---
  @override
  Future<String> createPromise({
    required String title,
    required String description,
    required DateTime startTime,
    required int durationMinutes,
    required bool isRecursive,
    required String category,
    required int priority,
    String? sharedBy,
  }) async {
    if (_userId == null) {
      throw Exception("User must be logged in to create a promise");
    }

    final participants = [_userId];

    final docRef = await _db.collection('promises').add({
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'isRecursive': isRecursive,
      'completedBy': [], // Initialize empty
      'createdBy': _userId,
      'createdAt': FieldValue.serverTimestamp(),
      'category': category,
      'priority': priority,
      'sharedBy': sharedBy,
      'participants': participants,
      'pendingParticipants': [],
      'completedDates': [],
    });

    return docRef.id;
  }

  @override
  Stream<List<PromiseModel>> getPromisesStream() {
    if (_userId == null) return Stream.value([]);

    return _db
        .collection('promises')
        .where('participants', arrayContains: _userId)
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
    if (_userId == null) throw Exception("User must be logged in");
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
      'createdBy': uid,
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
    if (_userId == null) throw Exception("User must be logged in");
    await _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats')
        .set(stats.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateCoins(int amount) async {
    if (_userId == null) throw Exception("User must be logged in");
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

  @override
  Future<void> incrementCompletedPromises() async {
    if (_userId == null) return;
    final ref = _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats');
    await ref.set({
      'totalPromisesCompleted': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateStreak(int currentStreak, String? lastStreakDate) async {
    if (_userId == null) return;
    final ref = _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats');
    await ref.set({
      'currentStreak': currentStreak,
      'lastStreakDate': lastStreakDate,
    }, SetOptions(merge: true));
  }

  // --- PROMISE REQUESTS IMPLEMENTATION ---

  @override
  Future<void> sendPromiseRequest(
      String targetUid,
      PromiseRequestModel request,
      ) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(targetUid)
        .collection('promise_requests')
        .add(request.toMap());

    if (request.linkedPromiseId != null &&
        request.linkedPromiseId!.isNotEmpty) {
      await _db.collection('promises').doc(request.linkedPromiseId).update({
        'pendingParticipants': FieldValue.arrayUnion([targetUid]),
      });
    }
  }

  @override
  Stream<List<PromiseRequestModel>> getPromiseRequestsStream() {
    if (_userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(_userId)
        .collection('promise_requests')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => PromiseRequestModel.fromFirestore(doc))
          .toList(),
    );
  }

  @override
  Future<void> acceptPromiseRequest(PromiseRequestModel request) async {
    if (_userId == null) return;

    bool sharedSuccessfully = false;

    if (request.linkedPromiseId != null) {
      final docRef = _db.collection('promises').doc(request.linkedPromiseId);
      try {
        await docRef.update({
          'participants': FieldValue.arrayUnion([_userId]),
          'pendingParticipants': FieldValue.arrayRemove([_userId]),
        });
        sharedSuccessfully = true;
      } catch (e) {
        print("Could not link to shared promise: $e");
      }
    }

    if (!sharedSuccessfully) {
      final int duration = request.endTime
          .difference(request.startTime)
          .inMinutes;
      await createPromise(
        title: request.title,
        description: request.description,
        startTime: request.startTime,
        durationMinutes: duration,
        isRecursive: false,
        category: request.category,
        priority: request.priority,
        sharedBy: request.senderName,
      );
    }

    await declinePromiseRequest(request.id);
  }

  @override
  Future<void> declinePromiseRequest(String requestId) async {
    if (_userId == null) return;

    final requestRef = _db
        .collection('users')
        .doc(_userId)
        .collection('promise_requests')
        .doc(requestId);

    final docSnap = await requestRef.get();
    if (docSnap.exists) {
      final data = docSnap.data();
      final linkedId = data?['linkedPromiseId'];

      if (linkedId != null && linkedId is String && linkedId.isNotEmpty) {
        try {
          await _db.collection('promises').doc(linkedId).update({
            'pendingParticipants': FieldValue.arrayRemove([_userId]),
          });
        } catch (e) {
          // Promise might be deleted already
        }
      }
    }

    await requestRef.delete();
  }

  @override
  Future<void> equipBadge(String badgeId) async {
    if (_userId == null) return;
    final ref = _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats');
    await ref.set({
      'equippedBadges': [badgeId],
    }, SetOptions(merge: true));
  }

  @override
  Future<void> equipAvatar(String avatarId) async {
    if (_userId == null) return;
    final ref = _db
        .collection('users')
        .doc(_userId)
        .collection('gamification')
        .doc('stats');
    await ref.set({'equippedAvatar': avatarId}, SetOptions(merge: true));
  }
}