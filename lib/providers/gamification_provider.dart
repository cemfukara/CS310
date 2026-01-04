import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_stats_model.dart';
import '../services/database_service.dart';

class GamificationProvider extends ChangeNotifier {
  DatabaseService _db;
  UserStatsModel _stats = UserStatsModel();
  bool _isLoading = true;

  UserStatsModel get stats => _stats;
  bool get isLoading => _isLoading;

  GamificationProvider(this._db) {
    _init();
  }

  void updateDatabase(DatabaseService db) {
    _db = db;
    _isLoading = true;
    notifyListeners();
    _init();
  }

  void _init() {
    _db.getUserStatsStream().listen((stats) {
      _stats = stats;
      _isLoading = false;
      _checkAchievements();
      notifyListeners();
    });
  }

  final List<Map<String, dynamic>> _achievementDefinitions = [
    {'id': 'first_promise', 'target': 1, 'type': 'promise_count'},
    {'id': 'promise_master', 'target': 50, 'type': 'promise_count'},
    {'id': 'century_club', 'target': 100, 'type': 'promise_count'},
    {'id': 'week_warrior', 'target': 7, 'type': 'streak'},
    {'id': 'consistency_king', 'target': 30, 'type': 'streak'},
    {'id': 'social_butterfly', 'target': 10, 'type': 'friends'},
    {'id': 'collector', 'target': 20, 'type': 'collector'},
    {'id': 'perfect_day', 'target': 1, 'type': 'perfect_day'},
  ];

  void _checkAchievements() {
    for (var def in _achievementDefinitions) {
      if (hasAchievement(def['id'])) continue;

      bool shouldUnlock = false;
      switch (def['type']) {
        case 'promise_count':
          if (_stats.totalPromisesCompleted >= def['target']) {
            shouldUnlock = true;
          }
          break;
        case 'streak':
          if (_stats.currentStreak >= def['target']) {
            shouldUnlock = true;
          }
          break;
        case 'friends':
          // We don't have totalFriends in stats yet, but we could add it
          // or just check the friends stream. For now, we focus on what we have.
          break;
      }

      if (shouldUnlock) {
        unlockAchievement(def['id']);
      }
    }
  }

  // --- ACTIONS ---

  Future<void> unlockAchievement(String id) async {
    await _db.unlockAchievement(id);
  }

  Future<void> handlePromiseCompletion() async {
    // 1. Increment total count
    await _db.incrementCompletedPromises();

    // 2. Update Streak
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_stats.lastStreakDate != today) {
      int newStreak = 1;

      if (_stats.lastStreakDate != null) {
        final lastDate = DateFormat('yyyy-MM-dd').parse(_stats.lastStreakDate!);
        final diff = DateTime.now().difference(lastDate).inDays;

        if (diff == 1) {
          newStreak = _stats.currentStreak + 1;
        } else if (diff == 0) {
          newStreak = _stats.currentStreak; // Already completed today
        }
      }

      await _db.updateStreak(newStreak, today);
    }
  }

  Future<bool> buyItem(String itemId, int price) async {
    if (_stats.coins >= price) {
      // 1. Deduct coins
      await _db.updateCoins(-price);
      // 2. Add to inventory
      await _db.unlockItem(itemId);
      return true; // Success
    } else {
      return false; // Not enough money
    }
  }

  bool hasItem(String itemId) {
    return _stats.inventory.contains(itemId);
  }

  int getAchievementProgress(String id) {
    if (hasAchievement(id)) {
      final def = _achievementDefinitions.firstWhere(
        (d) => d['id'] == id,
        orElse: () => {'target': 0},
      );
      return def['target'] as int;
    }

    final def = _achievementDefinitions.firstWhere(
      (d) => d['id'] == id,
      orElse: () => {'target': 0, 'type': 'unknown'},
    );

    switch (def['type']) {
      case 'promise_count':
        return _stats.totalPromisesCompleted;
      case 'streak':
        return _stats.currentStreak;
      case 'collector':
        return _stats.inventory.length;
      case 'friends':
        return 0; // Needs FriendsProvider or DB query
      case 'perfect_day':
        return 0; // Complex daily check
      default:
        return 0;
    }
  }

  bool hasAchievement(String achievementId) {
    return _stats.achievements.contains(achievementId);
  }

  // Debug/Dev helper
  Future<void> addFreeCoins(int amount) async {
    await _db.updateCoins(amount);
  }

  // equipBadge
  Future<void> equipBadge(String badgeId) async {
    await _db.equipBadge(badgeId);
  }

  // equipAvatar
  Future<void> equipAvatar(String avatarId) async {
    await _db.equipAvatar(avatarId);
  }
}
