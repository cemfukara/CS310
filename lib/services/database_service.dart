import '../models/promise_model.dart';

abstract class DatabaseService {
  Future<void> createPromise({
    required String title,
    required String description,
    required DateTime startTime, // Changed
    required DateTime endTime,   // Changed
    required bool isRecursive,   // Added
    required String category,
    required int priority,
  });

  Stream<List<PromiseModel>> getPromisesStream();
  Future<void> updatePromise(PromiseModel promise);
  Future<void> deletePromise(String promiseId);
}