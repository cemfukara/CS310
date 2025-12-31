import 'dart:async';
import 'package:flutter/material.dart';
import '../models/promise_model.dart';
import '../services/database_service.dart';

class PromiseProvider with ChangeNotifier {
  DatabaseService _db;
  StreamSubscription<List<PromiseModel>>? _promisesSubscription;

  List<PromiseModel> _promises = [];
  bool _isLoading = true;

  PromiseProvider(this._db) {
    _listenToPromises();
  }

  // --- PROXY UPDATE ---
  void update(DatabaseService newDb) {
    _db = newDb;
  }

  // --- GETTERS ---
  List<PromiseModel> get promises => _promises;
  bool get isLoading => _isLoading;

  // --- LISTENERS ---
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

  // --- CREATE ---
  // I kept the name 'createPromise' but it takes a full PromiseModel object
  // to make it easier to call from your screens.
  Future<void> createPromise(PromiseModel promise) async {
    try {
      // We pass the individual fields to the DB service
      await _db.createPromise(
        title: promise.title,
        description: promise.description,
        startTime: promise.startTime,
        endTime: promise.endTime,
        isRecursive: promise.isRecursive,
        category: promise.category,
        priority: promise.priority,
      );
      // Check for "First Promise" achievement
      // We can just try to unlock it every time, the backend handles duplicates via arrayUnion/set
      await _db.unlockAchievement('first_promise');
    } catch (e) {
      print("Error creating promise: $e");
      rethrow;
    }
  }

  // --- UPDATE (This was missing!) ---
  Future<void> updatePromise(PromiseModel promise) async {
    try {
      // 1. Optimistic Update (Update local list instantly)
      final index = _promises.indexWhere((p) => p.id == promise.id);
      if (index != -1) {
        _promises[index] = promise;
        notifyListeners();
      }

      // 2. Send to DB
      await _db.updatePromise(promise);
    } catch (e) {
      print("Error updating promise: $e");
      // If error, revert by re-fetching
      _listenToPromises();
      rethrow;
    }
  }

  // --- DELETE ---
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

  // --- TOGGLE STATUS ---
  Future<void> toggleStatus(String id, bool newStatus) async {
    try {
      final index = _promises.indexWhere((p) => p.id == id);
      if (index != -1) {
        final promise = _promises[index];
        final updatedPromise = promise.copyWith(isCompleted: newStatus);

        _promises[index] = updatedPromise;
        notifyListeners();

        await _db.updatePromise(updatedPromise);

        if (newStatus == true) {
          await _db.updateCoins(50);
        }
      }
    } catch (e) {
      print("Error toggling status: $e");
      _listenToPromises();
    }
  }

  @override
  void dispose() {
    _promisesSubscription?.cancel();
    super.dispose();
  }
}
