import 'package:flutter_test/flutter_test.dart';
import 'package:promise/models/promise_model.dart';

void main() {
  group('PromiseModel Tests', () {
    final startTime = DateTime(2025, 1, 1, 10, 0);
    final createdAt = DateTime(2025, 1, 1, 9, 0);
    const durationMinutes = 60;

    test('endTime calculation should be correct', () {
      final promise = PromiseModel(
        id: '1',
        title: 'Test',
        description: 'Test Desc',
        startTime: startTime,
        durationMinutes: durationMinutes,
        isRecursive: false,
        createdBy: 'user1',
        createdAt: createdAt,
        category: 'Work',
      );

      expect(
        promise.endTime,
        startTime.add(const Duration(minutes: durationMinutes)),
      );
    });

    test('toMap should include all fields', () {
      final promise = PromiseModel(
        id: '1',
        title: 'Test',
        description: 'Test Desc',
        startTime: startTime,
        durationMinutes: durationMinutes,
        isRecursive: true,
        isCompleted: false,
        createdBy: 'user1',
        createdAt: createdAt,
        category: 'Work',
        priority: 2,
        sharedBy: 'friend1',
        participants: const ['user1'],
        completedDates: const ['2025-01-01'],
      );

      final mapped = promise.toMap();

      expect(mapped['title'], 'Test');
      expect(mapped['isRecursive'], true);
      expect(mapped['priority'], 2);
      expect(mapped['completedDates'], const ['2025-01-01']);
      expect(mapped['sharedBy'], 'friend1');
    });

    test('copyWith should only update specified fields', () {
      final promise = PromiseModel(
        id: '1',
        title: 'Original',
        description: 'Original',
        startTime: startTime,
        durationMinutes: durationMinutes,
        isRecursive: false,
        createdBy: 'user1',
        createdAt: createdAt,
        category: 'Work',
      );

      final updated = promise.copyWith(title: 'Updated');

      expect(updated.title, 'Updated');
      expect(updated.description, 'Original');
      expect(updated.id, '1');
    });
  });
}
