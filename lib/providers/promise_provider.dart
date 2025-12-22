import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/material.dart';
import '../models/promise_model.dart';
import '../services/database_service.dart';

class PromiseProvider with ChangeNotifier {
  final DatabaseService _db;
  StreamSubscription<List<PromiseModel>>? _promisesSubscription;

  List<PromiseModel> _promises = [];
  bool _isLoading = true;

  // Constructor receives the DB service
  PromiseProvider(this._db) {
    _listenToPromises();
  }

  List<PromiseModel> get promises => _promises;
  bool get isLoading => _isLoading;

  // Listen to real-time updates from Firestore
  void _listenToPromises() {
    _isLoading = true;
    notifyListeners();

    _promisesSubscription?.cancel(); // Cancel any existing subscription

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

  // RELOAD METHOD
  Future<void> reload() async {
    _listenToPromises();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // CREATE
  Future<void> addPromise({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isRecursive,
    required String category,
    required int priority,
  }) async {
    await _db.createPromise(
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isRecursive: isRecursive,
      category: category,
      priority: priority,
    );
  }

  // UPDATE
  Future<void> updatePromise(PromiseModel promise) async {
    try {
      await _db.updatePromise(promise);
    } catch (e) {
      print("Error updating promise: $e");
      rethrow;
    }
  }

  // --- DELETE (FIXED: Optimistic Update) ---
  Future<void> deletePromise(String id) async {
    try {
      // 1. Remove from local list IMMEDIATELY so it vanishes from screen
      _promises.removeWhere((p) => p.id == id);
      notifyListeners();

      // 2. Then Delete from Database
      await _db.deletePromise(id);
    } catch (e) {
      print("Error deleting promise: $e");
      // If there was an error, re-fetch the list to bring it back
      _listenToPromises();
    }
  }

  // TOGGLE STATUS
  Future<void> toggleStatus(String id, bool newStatus) async {
    try {
      final index = _promises.indexWhere((p) => p.id == id);
      if (index != -1) {
        final promise = _promises[index];
        final updatedPromise = promise.copyWith(isCompleted: newStatus);

        // Optimistic update
        _promises[index] = updatedPromise;
        notifyListeners();

        await _db.updatePromise(updatedPromise);
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