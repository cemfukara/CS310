class UserStatsModel {
  final int coins;
  final int xp;
  final int level;
  final List<String> inventory; // List of item IDs owned
  final List<String> achievements; // List of achievement IDs unlocked
  final List<String> equippedBadges; // List of equipped badges
  final String? equippedAvatar; // ID/Name of the equipped avatar
  final int totalPromisesCompleted;
  final int currentStreak;

  UserStatsModel({
    this.coins = 0,
    this.xp = 0,
    this.level = 1,
    this.inventory = const [],
    this.achievements = const [],
    this.equippedBadges = const [],
    this.equippedAvatar,
    this.totalPromisesCompleted = 0,
    this.currentStreak = 0,
  });

  factory UserStatsModel.fromMap(Map<String, dynamic> data) {
    return UserStatsModel(
      coins: data['coins'] ?? 0,
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      inventory: List<String>.from(data['inventory'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      equippedBadges: List<String>.from(data['equippedBadges'] ?? []),
      equippedAvatar: data['equippedAvatar'],
      totalPromisesCompleted: data['totalPromisesCompleted'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coins': coins,
      'xp': xp,
      'level': level,
      'inventory': inventory,
      'achievements': achievements,
      'equippedBadges': equippedBadges,
      'equippedAvatar': equippedAvatar,
      'totalPromisesCompleted': totalPromisesCompleted,
      'currentStreak': currentStreak,
    };
  }
}
