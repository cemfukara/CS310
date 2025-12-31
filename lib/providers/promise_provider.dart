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
    notifyListeners();
  }

  List<PromiseModel> get promises => _promises;
  bool get isLoading => _isLoading;

  void _listenToPromises() {
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

  // --- UPDATED ADD METHOD ---
  Future<void> addPromise({
    required String title,
    required String description,
    required DateTime startTime,
    required int durationMinutes, // Updated
    required bool isRecursive,
    required String category,
    required int priority,
  }) async {
    await _db.createPromise(
      title: title,
      description: description,
      startTime: startTime,
      durationMinutes: durationMinutes, // Updated
      isRecursive: isRecursive,
      category: category,
      priority: priority,
    );
    await _db.unlockAchievement('first_promise');
  }

  Future<void> updatePromise(PromiseModel promise) async {
    try {
      await _db.updatePromise(promise);
    } catch (e) {
      print("Error updating promise: $e");
      rethrow;
    }
  }

  Future<void> deletePromise(String id) async {
    try {
      _promises.removeWhere((p) => p.id == id);
      notifyListeners();
      await _db.deletePromise(id);
    } catch (e) {
      print("Error deleting promise: $e");
      _listenToPromises();
    }
  }

  Future<void> toggleStatus(String id, bool newStatus) async {
    try {
      final index = _promises.indexWhere((p) => p.id == id);
      if (index != -1) {
        final promise = _promises[index];
        final updatedPromise = promise.copyWith(isCompleted: newStatus);

        _promises[index] = updatedPromise;
        notifyListeners();

        await _db.updatePromise(updatedPromise);
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