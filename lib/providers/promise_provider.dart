import 'package:flutter/material.dart';
import '../models/promise_model.dart';
import '../services/database_service.dart';

class PromiseProvider with ChangeNotifier {
  final DatabaseService _db;

  List<PromiseModel> _promises = [];
  bool _isLoading = true;

  // Constructor receives the DB service (which contains the User ID)
  PromiseProvider(this._db) {
    _listenToPromises();
  }

  List<PromiseModel> get promises => _promises;
  bool get isLoading => _isLoading;

  // Listen to real-time updates from Firestore
  void _listenToPromises() {
    _db.promises.listen((promiseList) {
      _promises = promiseList;
      _isLoading = false;
      notifyListeners(); // Notify UI to rebuild [cite: 40, 43]
    });
  }

  // Operations that the UI will call
  Future<void> addPromise(PromiseModel promise) async {
    await _db.addPromise(promise);
  }

  Future<void> updatePromise(PromiseModel promise) async {
    await _db.updatePromise(promise);
  }

  Future<void> deletePromise(String id) async {
    await _db.deletePromise(id);
  }

  Future<void> toggleStatus(String id, bool status) async {
    await _db.togglePromiseStatus(id, status);
  }
}