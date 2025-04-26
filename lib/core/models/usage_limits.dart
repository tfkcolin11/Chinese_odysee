import 'package:equatable/equatable.dart';

/// Model representing usage limits and current usage for a user
class UsageLimits extends Equatable {
  /// ID of the user
  final String userId;
  
  /// Start of the current usage period (e.g., midnight UTC)
  final DateTime periodStartTimestamp;
  
  /// Maximum number of conversation turns per day (null = unlimited)
  final int? dailyTurnsLimit;
  
  /// Number of conversation turns used today
  final int dailyTurnsUsed;
  
  /// Maximum number of pre-learning generations per day (null = unlimited)
  final int? dailyPrelearnLimit;
  
  /// Number of pre-learning generations used today
  final int dailyPrelearnUsed;
  
  /// Maximum number of custom scenarios (null = unlimited)
  final int? customScenarioLimit;
  
  /// Number of custom scenarios created
  final int customScenariosCreated;
  
  /// Maximum number of saved conversation instances (null = unlimited)
  final int? savedInstanceLimit;
  
  /// Number of conversation instances saved
  final int instancesSaved;

  /// Creates a new [UsageLimits] instance
  const UsageLimits({
    required this.userId,
    required this.periodStartTimestamp,
    this.dailyTurnsLimit,
    required this.dailyTurnsUsed,
    this.dailyPrelearnLimit,
    required this.dailyPrelearnUsed,
    this.customScenarioLimit,
    required this.customScenariosCreated,
    this.savedInstanceLimit,
    required this.instancesSaved,
  });

  /// Creates a [UsageLimits] from a map
  factory UsageLimits.fromMap(Map<String, dynamic> map) {
    return UsageLimits(
      userId: map['userId'] as String,
      periodStartTimestamp: DateTime.parse(map['periodStartTimestamp'] as String),
      dailyTurnsLimit: map['dailyTurnsLimit'] as int?,
      dailyTurnsUsed: map['dailyTurnsUsed'] as int,
      dailyPrelearnLimit: map['dailyPrelearnLimit'] as int?,
      dailyPrelearnUsed: map['dailyPrelearnUsed'] as int,
      customScenarioLimit: map['customScenarioLimit'] as int?,
      customScenariosCreated: map['customScenariosCreated'] as int,
      savedInstanceLimit: map['savedInstanceLimit'] as int?,
      instancesSaved: map['instancesSaved'] as int,
    );
  }

  /// Converts this [UsageLimits] to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'periodStartTimestamp': periodStartTimestamp.toIso8601String(),
      'dailyTurnsLimit': dailyTurnsLimit,
      'dailyTurnsUsed': dailyTurnsUsed,
      'dailyPrelearnLimit': dailyPrelearnLimit,
      'dailyPrelearnUsed': dailyPrelearnUsed,
      'customScenarioLimit': customScenarioLimit,
      'customScenariosCreated': customScenariosCreated,
      'savedInstanceLimit': savedInstanceLimit,
      'instancesSaved': instancesSaved,
    };
  }

  /// Creates a copy of this [UsageLimits] with the given fields replaced
  UsageLimits copyWith({
    String? userId,
    DateTime? periodStartTimestamp,
    int? dailyTurnsLimit,
    int? dailyTurnsUsed,
    int? dailyPrelearnLimit,
    int? dailyPrelearnUsed,
    int? customScenarioLimit,
    int? customScenariosCreated,
    int? savedInstanceLimit,
    int? instancesSaved,
  }) {
    return UsageLimits(
      userId: userId ?? this.userId,
      periodStartTimestamp: periodStartTimestamp ?? this.periodStartTimestamp,
      dailyTurnsLimit: dailyTurnsLimit ?? this.dailyTurnsLimit,
      dailyTurnsUsed: dailyTurnsUsed ?? this.dailyTurnsUsed,
      dailyPrelearnLimit: dailyPrelearnLimit ?? this.dailyPrelearnLimit,
      dailyPrelearnUsed: dailyPrelearnUsed ?? this.dailyPrelearnUsed,
      customScenarioLimit: customScenarioLimit ?? this.customScenarioLimit,
      customScenariosCreated: customScenariosCreated ?? this.customScenariosCreated,
      savedInstanceLimit: savedInstanceLimit ?? this.savedInstanceLimit,
      instancesSaved: instancesSaved ?? this.instancesSaved,
    );
  }

  /// Whether the user has reached the daily turns limit
  bool get hasDailyTurnsLimitReached {
    if (dailyTurnsLimit == null) return false;
    return dailyTurnsUsed >= dailyTurnsLimit!;
  }

  /// Whether the user has reached the daily pre-learn limit
  bool get hasDailyPrelearnLimitReached {
    if (dailyPrelearnLimit == null) return false;
    return dailyPrelearnUsed >= dailyPrelearnLimit!;
  }

  /// Whether the user has reached the custom scenario limit
  bool get hasCustomScenarioLimitReached {
    if (customScenarioLimit == null) return false;
    return customScenariosCreated >= customScenarioLimit!;
  }

  /// Whether the user has reached the saved instance limit
  bool get hasSavedInstanceLimitReached {
    if (savedInstanceLimit == null) return false;
    return instancesSaved >= savedInstanceLimit!;
  }

  /// Number of daily turns remaining
  int get dailyTurnsRemaining {
    if (dailyTurnsLimit == null) return -1; // -1 indicates unlimited
    return dailyTurnsLimit! - dailyTurnsUsed;
  }

  /// Number of daily pre-learn generations remaining
  int get dailyPrelearnRemaining {
    if (dailyPrelearnLimit == null) return -1; // -1 indicates unlimited
    return dailyPrelearnLimit! - dailyPrelearnUsed;
  }

  /// Number of custom scenarios remaining
  int get customScenariosRemaining {
    if (customScenarioLimit == null) return -1; // -1 indicates unlimited
    return customScenarioLimit! - customScenariosCreated;
  }

  /// Number of saved instances remaining
  int get savedInstancesRemaining {
    if (savedInstanceLimit == null) return -1; // -1 indicates unlimited
    return savedInstanceLimit! - instancesSaved;
  }

  @override
  List<Object?> get props => [
        userId,
        periodStartTimestamp,
        dailyTurnsLimit,
        dailyTurnsUsed,
        dailyPrelearnLimit,
        dailyPrelearnUsed,
        customScenarioLimit,
        customScenariosCreated,
        savedInstanceLimit,
        instancesSaved,
      ];
}
