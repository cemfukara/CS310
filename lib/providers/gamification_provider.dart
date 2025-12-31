import 'package:flutter/material.dart';
import '../models/user_stats_model.dart';
import '../services/database_service.dart';

class GamificationProvider extends ChangeNotifier {
  final DatabaseService _db;
  UserStatsModel _stats = UserStatsModel();
  bool _isLoading = true;

  UserStatsModel get stats => _stats;
  bool get isLoading => _isLoading;

  GamificationProvider(this._db) {
    _init();
  }

  void _init() {
    _db.getUserStatsStream().listen((stats) {
      _stats = stats;
      _isLoading = false;
      notifyListeners();
    });
  }

  // --- ACTIONS ---

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

  bool hasAchievement(String achievementId) {
    return _stats.achievements.contains(achievementId);
  }

  // Debug/Dev helper
  Future<void> addFreeCoins(int amount) async {
    await _db.updateCoins(amount);
  }
}
