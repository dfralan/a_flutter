import 'dart:convert';
import '../models/relay.dart';
import 'secure_database.dart';

class RelayService {
  static const List<String> _defaultRelays = [
    'wss://relay.damus.io',
    'wss://nos.lol',
    'wss://relay.snort.social',
    'wss://offchain.pub',
    'wss://relay.nostr.band',
    'wss://relay.nostr.wirednet.jp',
    'wss://nostr.wine',
  ];

  /// Get default relays
  static List<Relay> getDefaultRelays() {
    return _defaultRelays.map((url) {
      final domain = _extractDomain(url);
      return Relay(
        id: 'default_${url.hashCode}',
        url: url,
        name: domain,
        isEnabled: true,
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  /// Extract domain from URL
  static String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  /// Create a new relay
  static Future<Relay> createRelay(String url, String name) async {
    final relay = Relay(
      id: '${DateTime.now().millisecondsSinceEpoch}_${url.hashCode}',
      url: url,
      name: name,
      isEnabled: true,
      createdAt: DateTime.now(),
    );
    
    await saveRelay(relay);
    return relay;
  }

  /// Save relay to database
  static Future<void> saveRelay(Relay relay) async {
    final db = await SecureDatabase.database;
    
    await db.insert(
      'relay_connections',
      {
        'id': relay.id,
        'url': relay.url,
        'name': relay.name,
        'is_enabled': relay.isEnabled ? 1 : 0,
        'is_connected': relay.isConnected ? 1 : 0,
        'last_connected': relay.lastConnected?.toIso8601String(),
        'connection_count': relay.connectionCount,
        'success_count': relay.successCount,
        'failure_count': relay.failureCount,
        'metadata': json.encode(relay.metadata),
        'created_at': relay.createdAt.toIso8601String(),
        'last_used': relay.lastUsed?.toIso8601String(),
      },
    );
  }

  /// Load all relays from database
  static Future<List<Relay>> loadRelays() async {
    final db = await SecureDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('relay_connections');
    
    final List<Relay> relays = [];
    
    for (final map in maps) {
      final metadata = map['metadata'] != null 
          ? Map<String, dynamic>.from(json.decode(map['metadata']))
          : <String, dynamic>{};
      
      relays.add(Relay(
        id: map['id'],
        url: map['url'],
        name: map['name'],
        isEnabled: map['is_enabled'] == 1,
        isConnected: map['is_connected'] == 1,
        lastConnected: map['last_connected'] != null 
            ? DateTime.parse(map['last_connected']) 
            : null,
        connectionCount: map['connection_count'] ?? 0,
        successCount: map['success_count'] ?? 0,
        failureCount: map['failure_count'] ?? 0,
        metadata: metadata,
        createdAt: DateTime.parse(map['created_at']),
        lastUsed: map['last_used'] != null 
            ? DateTime.parse(map['last_used']) 
            : null,
      ));
    }
    
    return relays;
  }

  /// Get a specific relay by ID
  static Future<Relay?> getRelay(String id) async {
    final db = await SecureDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'relay_connections',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    final metadata = map['metadata'] != null 
        ? Map<String, dynamic>.from(json.decode(map['metadata']))
        : <String, dynamic>{};
    
    return Relay(
      id: map['id'],
      url: map['url'],
      name: map['name'],
      isEnabled: map['is_enabled'] == 1,
      isConnected: map['is_connected'] == 1,
      lastConnected: map['last_connected'] != null 
          ? DateTime.parse(map['last_connected']) 
          : null,
      connectionCount: map['connection_count'] ?? 0,
      successCount: map['success_count'] ?? 0,
      failureCount: map['failure_count'] ?? 0,
      metadata: metadata,
      createdAt: DateTime.parse(map['created_at']),
      lastUsed: map['last_used'] != null 
          ? DateTime.parse(map['last_used']) 
          : null,
    );
  }

  /// Delete a relay
  static Future<void> deleteRelay(String id) async {
    final db = await SecureDatabase.database;
    await db.delete(
      'relay_connections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update relay connection status
  static Future<void> updateRelayStatus(String id, bool isConnected) async {
    final relay = await getRelay(id);
    if (relay == null) return;
    
    final updatedRelay = relay.copyWith(
      isConnected: isConnected,
      lastConnected: isConnected ? DateTime.now() : relay.lastConnected,
      connectionCount: relay.connectionCount + 1,
    );
    
    await saveRelay(updatedRelay);
  }

  /// Update relay success/failure count
  static Future<void> updateRelayStats(String id, bool success) async {
    final relay = await getRelay(id);
    if (relay == null) return;
    
    final updatedRelay = relay.copyWith(
      successCount: relay.successCount + (success ? 1 : 0),
      failureCount: relay.failureCount + (success ? 0 : 1),
    );
    
    await saveRelay(updatedRelay);
  }

  /// Enable/disable a relay
  static Future<void> toggleRelay(String id, bool enabled) async {
    final relay = await getRelay(id);
    if (relay == null) return;
    
    final updatedRelay = relay.copyWith(
      isEnabled: enabled,
      isConnected: enabled ? relay.isConnected : false,
    );
    
    await saveRelay(updatedRelay);
  }

  /// Get enabled relays
  static Future<List<Relay>> getEnabledRelays() async {
    final relays = await loadRelays();
    return relays.where((relay) => relay.isEnabled).toList();
  }

  /// Get connected relays
  static Future<List<Relay>> getConnectedRelays() async {
    final relays = await loadRelays();
    return relays.where((relay) => relay.isConnected).toList();
  }

  /// Validate relay URL
  static bool isValidRelayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'wss' || uri.scheme == 'ws';
    } catch (e) {
      return false;
    }
  }

  /// Test relay connection (placeholder for now)
  static Future<bool> testRelayConnection(String url) async {
    // In a real implementation, you'd test the WebSocket connection
    // For now, we'll just validate the URL format
    return isValidRelayUrl(url);
  }

  /// Import relays from a list of URLs
  static Future<List<Relay>> importRelays(List<String> urls) async {
    final List<Relay> importedRelays = [];
    final existingRelays = await loadRelays();
    final existingUrls = existingRelays.map((r) => r.url).toSet();
    
    for (final url in urls) {
      if (isValidRelayUrl(url) && !existingUrls.contains(url)) {
        final domain = _extractDomain(url);
        final relay = await createRelay(url, domain);
        importedRelays.add(relay);
      }
    }
    
    return importedRelays;
  }

  /// Export relays as a list of URLs
  static Future<List<String>> exportRelays() async {
    final relays = await loadRelays();
    return relays.map((relay) => relay.url).toList();
  }

  /// Get relay statistics
  static Future<Map<String, dynamic>> getRelayStats() async {
    final relays = await loadRelays();
    
    final totalRelays = relays.length;
    final enabledRelays = relays.where((r) => r.isEnabled).length;
    final connectedRelays = relays.where((r) => r.isConnected).length;
    final totalConnections = relays.fold(0, (sum, r) => sum + r.connectionCount);
    final totalSuccess = relays.fold(0, (sum, r) => sum + r.successCount);
    final totalFailures = relays.fold(0, (sum, r) => sum + r.failureCount);
    
    return {
      'totalRelays': totalRelays,
      'enabledRelays': enabledRelays,
      'connectedRelays': connectedRelays,
      'totalConnections': totalConnections,
      'totalSuccess': totalSuccess,
      'totalFailures': totalFailures,
      'successRate': totalConnections > 0 ? (totalSuccess / totalConnections) * 100 : 0.0,
    };
  }
} 