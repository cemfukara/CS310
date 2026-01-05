import 'package:flutter_test/flutter_test.dart';
import 'package:promise/models/user_stats_model.dart';

void main() {
  group('UserStatsModel Tests', () {
    test('default values should be set correctly', () {
      final stats = UserStatsModel();

      expect(stats.coins, 0);
      expect(stats.xp, 0);
      expect(stats.level, 1);
      expect(stats.inventory, isEmpty);
      expect(stats.totalPromisesCompleted, 0);
      expect(stats.currentStreak, 0);
      expect(stats.lastStreakDate, isNull);
    });

    test('fromMap and toMap should be consistent', () {
      final data = {
        'coins': 100,
        'xp': 500,
        'level': 5,
        'inventory': ['item1', 'item2'],
        'achievements': ['ach1'],
        'equippedBadges': ['badge1'],
        'equippedAvatar': 'avatar1',
        'totalPromisesCompleted': 10,
        'currentStreak': 3,
        'lastStreakDate': '2025-01-01',
      };

      final stats = UserStatsModel.fromMap(data);
      final mapped = stats.toMap();

      expect(mapped['coins'], 100);
      expect(mapped['xp'], 500);
      expect(mapped['inventory'], ['item1', 'item2']);
      expect(mapped['lastStreakDate'], '2025-01-01');
    });

    test('fromMap should handle partial data', () {
      final data = {'coins': 50};

      final stats = UserStatsModel.fromMap(data);

      expect(stats.coins, 50);
      expect(stats.xp, 0);
      expect(stats.level, 1);
    });
  });
}
