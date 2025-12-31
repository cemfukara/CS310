import '../models/promise_model.dart';
import '../models/user_model.dart';
import '../models/user_stats_model.dart';
import '../models/promise_request_model.dart';

abstract class DatabaseService {
  // --- PROMISE METHODS ---
  Future<void> createPromise({
    required String title,
    required String description,
    required DateTime startTime,
    required int durationMinutes, // Kept User's Preference
    required bool isRecursive,
    required String category,
    required int priority,
    String? sharedBy,
  });

  Stream<List<PromiseModel>> getPromisesStream();
  Future<void> updatePromise(PromiseModel promise);
  Future<void> deletePromise(String promiseId);

  // --- FRIEND METHODS ---
  Future<void> createPublicUser(String uid, String email, String displayName);
  Future<UserModel?> searchUserByEmail(String email);
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
  Stream<List<UserModel>> getFriendRequestsStream();
  Stream<List<UserModel>> getFriendsStream();

  // --- GAMIFICATION METHODS ---
  Stream<UserStatsModel> getUserStatsStream();
  Future<void> updateUserStats(UserStatsModel stats);
  Future<void> updateCoins(int amount);
  Future<void> unlockItem(String itemId);
  Future<void> unlockAchievement(String achievementId);

  // --- PROMISE REQUESTS (New) ---
  Future<void> sendPromiseRequest(
    String targetUid,
    PromiseRequestModel request,
  );
  Stream<List<PromiseRequestModel>> getPromiseRequestsStream();
  Future<void> acceptPromiseRequest(PromiseRequestModel request);
  Future<void> declinePromiseRequest(String requestId);

  // Badge equip
  Future<void> equipBadge(String badges);
}
