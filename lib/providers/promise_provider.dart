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
    _listenToPromises();
  }

  List<PromiseModel> get promises => _promises;
  bool get isLoading => _isLoading;

  void _listenToPromises() {
    _promises = [];
    _isLoading = true;
    notifyListeners();

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

  // --- UPDATED TOGGLE STATUS ---
  Future<void> toggleStatus(
      String id,
      String uid, // Needs UID to bind completion to user
      bool newStatus, {
        DateTime? date,
      }) async {
    try {
      final index = _promises.indexWhere((p) => p.id == id);
      if (index != -1) {
        final promise = _promises[index];
        PromiseModel updatedPromise;

        if (promise.isRecursive && date != null) {
          // Recursive Logic: "yyyy-MM-dd_uid"
          final dateStr =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          final tag = "${dateStr}_$uid"; // Unique tag per user per date

          final newCompletedDates = List<String>.from(promise.completedDates);

          if (newStatus) {
            if (!newCompletedDates.contains(tag)) {
              newCompletedDates.add(tag);
            }
          } else {
            newCompletedDates.remove(tag);
          }
          updatedPromise = promise.copyWith(completedDates: newCompletedDates);
        } else {
          // Non-Recursive Logic: Add/Remove UID from completedBy
          final newCompletedBy = List<String>.from(promise.completedBy);
          if (newStatus) {
            if (!newCompletedBy.contains(uid)) {
              newCompletedBy.add(uid);
            }
          } else {
            newCompletedBy.remove(uid);
          }
          updatedPromise = promise.copyWith(completedBy: newCompletedBy);
        }

        // Optimistic Update
        _promises[index] = updatedPromise;
        notifyListeners();

        // Database Update
        await _db.updatePromise(updatedPromise);

        if (newStatus == true) {
          await _db.updateCoins(50);
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