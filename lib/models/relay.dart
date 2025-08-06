class Relay {
  final String id;
  final String url;
  final String name;
  final bool isEnabled;
  final bool isConnected;
  final DateTime? lastConnected;
  final int connectionCount;
  final int successCount;
  final int failureCount;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? lastUsed;

  Relay({
    required this.id,
    required this.url,
    required this.name,
    this.isEnabled = true,
    this.isConnected = false,
    this.lastConnected,
    this.connectionCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    Map<String, dynamic>? metadata,
    required this.createdAt,
    this.lastUsed,
  }) : metadata = metadata ?? {};

  Relay copyWith({
    String? id,
    String? url,
    String? name,
    bool? isEnabled,
    bool? isConnected,
    DateTime? lastConnected,
    int? connectionCount,
    int? successCount,
    int? failureCount,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return Relay(
      id: id ?? this.id,
      url: url ?? this.url,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      isConnected: isConnected ?? this.isConnected,
      lastConnected: lastConnected ?? this.lastConnected,
      connectionCount: connectionCount ?? this.connectionCount,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'name': name,
      'isEnabled': isEnabled,
      'isConnected': isConnected,
      'lastConnected': lastConnected?.toIso8601String(),
      'connectionCount': connectionCount,
      'successCount': successCount,
      'failureCount': failureCount,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  factory Relay.fromJson(Map<String, dynamic> json) {
    return Relay(
      id: json['id'],
      url: json['url'],
      name: json['name'],
      isEnabled: json['isEnabled'] ?? true,
      isConnected: json['isConnected'] ?? false,
      lastConnected: json['lastConnected'] != null 
          ? DateTime.parse(json['lastConnected']) 
          : null,
      connectionCount: json['connectionCount'] ?? 0,
      successCount: json['successCount'] ?? 0,
      failureCount: json['failureCount'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null 
          ? DateTime.parse(json['lastUsed']) 
          : null,
    );
  }

  /// Get success rate as percentage
  double get successRate {
    final total = successCount + failureCount;
    if (total == 0) return 0.0;
    return (successCount / total) * 100;
  }

  /// Get connection status description
  String get statusDescription {
    if (!isEnabled) return 'Disabled';
    if (isConnected) return 'Connected';
    if (lastConnected != null) return 'Last connected: ${_formatDate(lastConnected!)}';
    return 'Never connected';
  }

  /// Get relay domain from URL
  String get domain {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  /// Check if relay is a paid relay
  bool get isPaid {
    return metadata['paid'] == true;
  }

  /// Get relay location/country
  String? get location {
    return metadata['location'];
  }

  /// Get relay description
  String? get description {
    return metadata['description'];
  }

  /// Get relay contact information
  String? get contact {
    return metadata['contact'];
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 