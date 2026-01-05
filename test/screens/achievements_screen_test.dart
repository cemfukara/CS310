import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:promise/screens/achievements_screen.dart';
import 'package:promise/providers/gamification_provider.dart';
import 'package:promise/models/user_stats_model.dart';
import 'package:promise/services/database_service.dart';
import 'package:promise/models/promise_model.dart';
import 'package:promise/models/user_model.dart';
import 'package:promise/models/promise_request_model.dart';

class MockDatabaseService implements DatabaseService {
  @override
  Stream<UserStatsModel> getUserStatsStream() => Stream.value(UserStatsModel());
  @override
  Future<void> updateCoins(int amount) async {}
  @override
  Future<void> incrementCompletedPromises() async {}
  @override
  Future<void> updateStreak(int currentStreak, String? lastStreakDate) async {}
  @override
  Future<void> unlockAchievement(String achievementId) async {}
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
  }) async => '';
  @override
  Stream<List<PromiseModel>> getPromisesStream() => Stream.value([]);
  @override
  Future<void> updatePromise(PromiseModel promise) async {}
  @override
  Future<void> deletePromise(String promiseId) async {}
  @override
  Future<void> createPublicUser(
    String uid,
    String email,
    String displayName,
  ) async {}
  @override
  Future<UserModel?> searchUserByEmail(String email) async => null;
  @override
  Future<void> sendFriendRequest(
    String currentUid,
    String currentName,
    String currentEmail,
    String targetUid,
  ) async {}
  @override
  Future<void> acceptFriendRequest(
    String currentUid,
    String currentName,
    String currentEmail,
    String requestUid,
    String requestName,
    String requestEmail,
  ) async {}
  @override
  Future<void> declineFriendRequest(
    String currentUid,
    String requestUid,
  ) async {}
  @override
  Stream<List<UserModel>> getFriendRequestsStream() => Stream.value([]);
  @override
  Stream<List<UserModel>> getFriendsStream() => Stream.value([]);
  @override
  Future<void> updateUserStats(UserStatsModel stats) async {}
  @override
  Future<void> unlockItem(String itemId) async {}
  @override
  Future<void> sendPromiseRequest(
    String targetUid,
    PromiseRequestModel request,
  ) async {}
  @override
  Stream<List<PromiseRequestModel>> getPromiseRequestsStream() =>
      Stream.value([]);
  @override
  Future<void> acceptPromiseRequest(PromiseRequestModel request) async {}
  @override
  Future<void> declinePromiseRequest(String requestId) async {}
  @override
  Future<void> equipBadge(String badges) async {}
  @override
  Future<void> equipAvatar(String avatarId) async {}
}

void main() {
  testWidgets('AchievementsScreen renders correctly', (
    WidgetTester tester,
  ) async {
    final mockDb = MockDatabaseService();
    final provider = GamificationProvider(mockDb);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GamificationProvider>.value(
          value: provider,
          child: const AchievementsScreen(),
        ),
      ),
    );

    // Wait for the stream to emit
    await tester.pumpAndSettle();

    // Check for title
    expect(find.text('Achievements'), findsOneWidget);

    // Check for Overall Progress card
    expect(find.text('Overall Progress'), findsOneWidget);

    // Check for an achievement name
    expect(find.text('First Promise'), findsWidgets);
  });
}
