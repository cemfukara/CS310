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

  // CREATE: Matches the signature in DatabaseService
  Future<void> addPromise({
    required String title,
    required String description,
    required DateTime dueDate,
    required String category,
    required int priority,
  }) async {
    try {
      await _db.createPromise(
        title: title,
        description: description,
        dueDate: dueDate,
        category: category,
        priority: priority,
      );
    } catch (e) {
      print("Error adding promise: $e");
      rethrow; // Handle error in UI
    }
  }

  // UPDATE: Updates the full object
  Future<void> updatePromise(PromiseModel promise) async {
    try {
      await _db.updatePromise(promise);
    } catch (e) {
      print("Error updating promise: $e");
      rethrow;
    }
  }

  // DELETE
  Future<void> deletePromise(String id) async {
    try {
      await _db.deletePromise(id);
    } catch (e) {
      print("Error deleting promise: $e");
    }
  }

  // TOGGLE STATUS: Helper to toggle isCompleted without passing the whole object from UI
  Future<void> toggleStatus(String id, bool newStatus) async {
    try {
      // Find the promise in our local list so we can clone it
      final index = _promises.indexWhere((p) => p.id == id);
      if (index != -1) {
        final promise = _promises[index];
        final updatedPromise = promise.copyWith(isCompleted: newStatus);

        // Update in Firestore
        await _db.updatePromise(updatedPromise);
      }
    } catch (e) {
      print("Error toggling status: $e");
    }
  }

  @override
  void dispose() {
    _promisesSubscription?.cancel(); // STOP LISTENING when provider is destroyed
    super.dispose();
  }
}