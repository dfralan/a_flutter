class Watcher {
  final String id;
  final String name;
  final List<String> keywords;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastUsed;

  Watcher({
    required this.id,
    required this.name,
    required this.keywords,
    this.isEnabled = true,
    required this.createdAt,
    this.lastUsed,
  });

  Watcher copyWith({
    String? id,
    String? name,
    List<String>? keywords,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return Watcher(
      id: id ?? this.id,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'keywords': keywords,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  factory Watcher.fromJson(Map<String, dynamic> json) {
    return Watcher(
      id: json['id'],
      name: json['name'],
      keywords: List<String>.from(json['keywords'] ?? []),
      isEnabled: json['isEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed']) 
          : null,
    );
  }

  /// Check if a text matches any of the watcher's keywords
  bool matchesText(String text) {
    if (!isEnabled) return false;
    
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) {
      final lowerKeyword = keyword.toLowerCase();
      return lowerText.contains(lowerKeyword);
    });
  }

  /// Get display name with keyword count
  String get displayName {
    return '$name (${keywords.length})';
  }
} 