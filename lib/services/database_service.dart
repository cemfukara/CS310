import '../models/promise_model.dart';
import '../models/user_model.dart'; // Import the new model

abstract class DatabaseService {
  // --- PROMISE METHODS (EXISTING) ---
  Future<void> createPromise({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isRecursive,
    required String category,
    required int priority,
  });

  Stream<List<PromiseModel>> getPromisesStream();
  Future<void> updatePromise(PromiseModel promise);
  Future<void> deletePromise(String promiseId);

  // --- FRIEND METHODS (NEW) ---

  // 1. Create public user doc so they can be searched
  Future<void> createPublicUser(String uid, String email, String displayName);

  // 2. Search for a user by email
  Future<UserModel?> searchUserByEmail(String email);

  // 3. Send/Accept/Decline
  Future<void> sendFriendRequest(String currentUid, String currentName, String currentEmail, String targetUid);
  Future<void> acceptFriendRequest(String currentUid, String currentName, String currentEmail, String requestUid, String requestName, String requestEmail);
  Future<void> declineFriendRequest(String currentUid, String requestUid);

  // 4. Streams
  Stream<List<UserModel>> getFriendRequestsStream();
  Stream<List<UserModel>> getFriendsStream();
}