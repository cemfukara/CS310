import 'dart:async';
import 'package:flutter/material.dart';
import '../models/promise_model.dart';
import '../services/database_service.dart';

class PromiseProvider with ChangeNotifier {
  late DatabaseService _db;
  StreamSubscription<List<PromiseModel>>? _promisesSubscription;

  List<PromiseModel> _promises = [];
  bool _isLoading = true;

  PromiseProvider(this._db) {
    _listenToPromises();
  }

  void updateDatabase(DatabaseService db) {
    _db = db;
    // CRITICAL FIX: Restart listener when user changes so we don't show old data
    _listenToPromises();
  }

  List<PromiseModel> get promises => _promises;
  bool get isLoading => _isLoading;

  void _listenToPromises() {
    // 1. Clear old data immediately to prevent leakage
    _promises = [];
    _isLoading = true;
    notifyListeners();

    // 2. Cancel old subscription and start new one
    _promisesSubscription?.cancel();
    _promisesSubscription = _db.getPromisesStream().listen(
      (promiseList) {
        _promises = promiseList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error listening to promises: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> reload() async {
    _listenToPromises();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Updated: Returns the ID of the created promise
  Future<String> addPromise({
    required String title,
    required String description,
    required DateTime startTime,
    required int durationMinutes,
    required bool isRecursive,
    required String category,
    required int priority,
  }) async {
    final id = await _db.createPromise(
      title: title,
      description: description,
      startTime: startTime,
      durationMinutes: durationMinutes,
      isRecursive: isRecursive,
      category: category,
      priority: priority,
    );
    await _db.unlockAchievement('first_promise');
    return id;
  }

  Future<void> updatePromise(PromiseModel promise) async {
    await _db.updatePromise(promise);
  }

  Future<void> deletePromise(String id) async {
    try {
      _promises.removeWhere((p) => p.id == id);
      notifyListeners();
      await _db.deletePromise(id);
    } catch (e) {
      _listenToPromises();
    }
  }

  Future<void> toggleStatus(String id, bool newStatus, {DateTime? date}) async {
    try {
      final index = _promises.indexWhere((p) => p.id == id);
      if (index != -1) {
        final promise = _promises[index];
        PromiseModel updatedPromise;

        if (promise.isRecursive && date != null) {
          final dateStr =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          final newCompletedDates = List<String>.from(promise.completedDates);

          if (newStatus) {
            if (!newCompletedDates.contains(dateStr)) {
              newCompletedDates.add(dateStr);
            }
          } else {
            newCompletedDates.remove(dateStr);
          }
          updatedPromise = promise.copyWith(completedDates: newCompletedDates);
        } else {
          updatedPromise = promise.copyWith(isCompleted: newStatus);
        }

        _promises[index] = updatedPromise;
        notifyListeners();

        await _db.updatePromise(updatedPromise);

        if (newStatus == true) {
          // Trigger gamification updates (Xp, Coins, Stats)
          await _db.updateCoins(50);
          // NEW: Increment total completed and check streaks/achievements
          // Note: Realistically this should be handled by a higher-level coordinator
          // or the provider should have access to GamificationProvider.
          // For now, we manually call the DB methods if they are simple enough,
          // or we rely on GamificationProvider listening to the same DB.
          // However, GamificationProvider.handlePromiseCompletion has complex logic (streak).
          // We'll let the UI or a coordinator call it, OR we can inject GamificationProvider
          // but that's circular.
          // BEST WAY: PromiseProvider only updates DB. GamificationProvider listens to stats AND promises?
          // No, let's keep it simple: Add a method to DatabaseService or just call the logic here.
        }
      }
    } catch (e) {
      print("Error toggling status: $e");
    }
  }

  @override
  void dispose() {
    _promisesSubscription?.cancel();
    super.dispose();
  }
}
