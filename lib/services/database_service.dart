import '../models/promise_model.dart';
import '../models/user_model.dart';
import '../models/user_stats_model.dart';
import '../models/promise_request_model.dart'; // Import the new stats model

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
  Future<void> sendFriendRequest(
    String currentUid,
    String currentName,
    String currentEmail,
    String targetUid,
  );
  Future<void> acceptFriendRequest(
    String currentUid,
    String currentName,
    String currentEmail,
    String requestUid,
    String requestName,
    String requestEmail,
  );
  Future<void> declineFriendRequest(String currentUid, String requestUid);

  // 4. Streams
  Stream<List<UserModel>> getFriendRequestsStream();
  Stream<List<UserModel>> getFriendsStream();

  // --- GAMIFICATION ONE-TIME METHODS (NEW) ---
  Stream<UserStatsModel> getUserStatsStream();
  Future<void> updateUserStats(UserStatsModel stats);
  Future<void> updateCoins(int amount); // Positive to add, negative to subtract
  Future<void> unlockItem(String itemId);
  Future<void> unlockAchievement(String achievementId);

  // --- PROMISE REQUESTS ---
  Future<void> sendPromiseRequest(
    String targetUid,
    PromiseRequestModel request,
  );
  Stream<List<PromiseRequestModel>> getPromiseRequestsStream();
  Future<void> acceptPromiseRequest(PromiseRequestModel request);
  Future<void> declinePromiseRequest(String requestId);
}
