import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:promise/providers/gamification_provider.dart';
import 'package:promise/models/user_stats_model.dart';
import 'package:promise/services/database_service.dart';
import 'package:promise/models/promise_model.dart';
import 'package:promise/models/user_model.dart';
import 'package:promise/models/promise_request_model.dart';
import 'package:intl/intl.dart';

class MockDatabaseService implements DatabaseService {
  UserStatsModel _stats = UserStatsModel();
  final _statsController = StreamController<UserStatsModel>.broadcast();

  MockDatabaseService() {
    _statsController.add(_stats);
  }

  set stats(UserStatsModel s) {
    _stats = s;
    _statsController.add(_stats);
  }

  UserStatsModel get stats => _stats;

  @override
  Stream<UserStatsModel> getUserStatsStream() => _statsController.stream;

  @override
  Future<void> updateCoins(int amount) async {
    stats = UserStatsModel.fromMap({
      ...stats.toMap(),
      'coins': stats.coins + amount,
    });
  }

  @override
  Future<void> incrementCompletedPromises() async {
    stats = UserStatsModel.fromMap({
      ...stats.toMap(),
      'totalPromisesCompleted': stats.totalPromisesCompleted + 1,
    });
  }

  @override
  Future<void> updateStreak(int currentStreak, String? lastStreakDate) async {
    stats = UserStatsModel.fromMap({
      ...stats.toMap(),
      'currentStreak': currentStreak,
      'lastStreakDate': lastStreakDate,
    });
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    if (!stats.achievements.contains(achievementId)) {
      stats = UserStatsModel.fromMap({
        ...stats.toMap(),
        'achievements': [...stats.achievements, achievementId],
      });
    }
  }

  // Stubs
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
  @override
  Future<void> updateUserPublicProfile({
    String? displayName,
    String? email,
  }) async {}
}

void main() {
  group('GamificationProvider Tests', () {
    late GamificationProvider provider;
    late MockDatabaseService mockDb;

    setUp(() {
      mockDb = MockDatabaseService();
      provider = GamificationProvider(mockDb);
    });

    test('handlePromiseCompletion should increment total count', () async {
      await provider.handlePromiseCompletion();
      expect(mockDb.stats.totalPromisesCompleted, 1);
    });

    test(
      'handlePromiseCompletion should set streak to 1 on first day',
      () async {
        await provider.handlePromiseCompletion();
        expect(mockDb.stats.currentStreak, 1);
      },
    );

    test('consecutive day completion should increment streak', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      mockDb.stats = UserStatsModel(
        currentStreak: 1,
        lastStreakDate: DateFormat('yyyy-MM-dd').format(yesterday),
      );

      provider.updateDatabase(mockDb);
      await Future.delayed(Duration.zero);

      await provider.handlePromiseCompletion();
      expect(mockDb.stats.currentStreak, 2);
    });

    group('Achievement Logic', () {
      test('reaching 1 promise should unlock first_promise', () async {
        mockDb.stats = UserStatsModel(totalPromisesCompleted: 1);
        provider.updateDatabase(mockDb);
        await Future.delayed(Duration.zero);

        expect(provider.hasAchievement('first_promise'), isTrue);
      });
    });
  });
}
