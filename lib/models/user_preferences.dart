class UserPreferences {
  final String theme;
  final String language;
  final bool notificationsEnabled;
  final bool autoConnect;
  final List<String> defaultRelays;
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> displaySettings;
  final Map<String, dynamic> networkSettings;
  final Map<String, dynamic> _customPreferences;

  UserPreferences({
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
    required this.autoConnect,
    required this.defaultRelays,
    required this.privacySettings,
    required this.displaySettings,
    required this.networkSettings,
    Map<String, dynamic>? customPreferences,
  }) : _customPreferences = customPreferences ?? {};

  /// Create default preferences
  factory UserPreferences.defaults() {
    return UserPreferences(
      theme: 'dark',
      language: 'en',
      notificationsEnabled: true,
      autoConnect: false,
      defaultRelays: [
        'wss://relay.damus.io',
        'wss://nos.lol',
        'wss://relay.snort.social',
        'wss://offchain.pub',
      ],
      privacySettings: {
        'showReadReceipts': false,
        'showTypingIndicator': false,
        'allowDirectMessages': true,
        'allowMentions': true,
        'autoDeleteMessages': false,
        'messageRetentionDays': 30,
      },
      displaySettings: {
        'fontSize': 'medium',
        'showAvatars': true,
        'showUsernames': true,
        'showTimestamps': true,
        'compactMode': false,
        'showReactions': true,
        'showReposts': true,
      },
      networkSettings: {
        'connectionTimeout': 30,
        'maxReconnectAttempts': 5,
        'enableCompression': true,
        'enableEncryption': true,
        'autoReconnect': true,
      },
    );
  }

  /// Update a specific preference
  void updatePreference<T>(String key, T value) {
    _customPreferences[key] = value;
  }

  /// Get a specific preference
  T? getPreference<T>(String key) {
    return _customPreferences[key] as T?;
  }

  /// Create a copy with updated values
  UserPreferences copyWith({
    String? theme,
    String? language,
    bool? notificationsEnabled,
    bool? autoConnect,
    List<String>? defaultRelays,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? displaySettings,
    Map<String, dynamic>? networkSettings,
    Map<String, dynamic>? customPreferences,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoConnect: autoConnect ?? this.autoConnect,
      defaultRelays: defaultRelays ?? this.defaultRelays,
      privacySettings: privacySettings ?? this.privacySettings,
      displaySettings: displaySettings ?? this.displaySettings,
      networkSettings: networkSettings ?? this.networkSettings,
      customPreferences: customPreferences ?? Map.from(_customPreferences),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'autoConnect': autoConnect,
      'defaultRelays': defaultRelays,
      'privacySettings': privacySettings,
      'displaySettings': displaySettings,
      'networkSettings': networkSettings,
      'customPreferences': _customPreferences,
    };
  }

  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'dark',
      language: json['language'] ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      autoConnect: json['autoConnect'] ?? false,
      defaultRelays: List<String>.from(json['defaultRelays'] ?? []),
      privacySettings: Map<String, dynamic>.from(json['privacySettings'] ?? {}),
      displaySettings: Map<String, dynamic>.from(json['displaySettings'] ?? {}),
      networkSettings: Map<String, dynamic>.from(json['networkSettings'] ?? {}),
      customPreferences: Map<String, dynamic>.from(json['customPreferences'] ?? {}),
    );
  }

  /// Get all preferences as a map
  Map<String, dynamic> getAllPreferences() {
    final allPrefs = Map<String, dynamic>.from(toJson());
    allPrefs.addAll(_customPreferences);
    return allPrefs;
  }

  /// Check if a preference exists
  bool hasPreference(String key) {
    return _customPreferences.containsKey(key);
  }

  /// Remove a preference
  void removePreference(String key) {
    _customPreferences.remove(key);
  }

  /// Get all custom preferences
  Map<String, dynamic> get customPreferences => Map.unmodifiable(_customPreferences);

  /// Merge with another preferences object
  UserPreferences merge(UserPreferences other) {
    return UserPreferences(
      theme: other.theme,
      language: other.language,
      notificationsEnabled: other.notificationsEnabled,
      autoConnect: other.autoConnect,
      defaultRelays: other.defaultRelays,
      privacySettings: {...privacySettings, ...other.privacySettings},
      displaySettings: {...displaySettings, ...other.displaySettings},
      networkSettings: {...networkSettings, ...other.networkSettings},
      customPreferences: {..._customPreferences, ...other._customPreferences},
    );
  }
} 