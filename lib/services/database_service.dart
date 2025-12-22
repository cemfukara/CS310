import '../models/promise_model.dart';

abstract class DatabaseService {
  // CREATE
  Future<void> createPromise({
    required String title,
    required String description,
    required DateTime dueDate,
    required String category,
    required int priority,
  });

  // READ
  Stream<List<PromiseModel>> getPromisesStream();

  // UPDATE
  Future<void> updatePromise(PromiseModel promise);

  // DELETE
  Future<void> deletePromise(String promiseId);
}