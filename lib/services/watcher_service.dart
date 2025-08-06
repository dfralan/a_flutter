import 'dart:convert';
import '../models/watcher.dart';
import 'secure_database.dart';

class WatcherService {
  /// Create a new watcher
  static Future<Watcher> createWatcher(String name, List<String> keywords) async {
    final watcher = Watcher(
      id: '${DateTime.now().millisecondsSinceEpoch}_${name.hashCode}',
      name: name,
      keywords: keywords,
      createdAt: DateTime.now(),
    );
    
    await saveWatcher(watcher);
    return watcher;
  }

  /// Save watcher to database
  static Future<void> saveWatcher(Watcher watcher) async {
    final db = await SecureDatabase.database;
    
    await db.insert(
      'watchers',
      {
        'id': watcher.id,
        'name': watcher.name,
        'keywords': json.encode(watcher.keywords),
        'is_enabled': watcher.isEnabled ? 1 : 0,
        'created_at': watcher.createdAt.toIso8601String(),
        'last_used': watcher.lastUsed?.toIso8601String(),
      },
    );
  }

  /// Load all watchers from database
  static Future<List<Watcher>> loadWatchers() async {
    final db = await SecureDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('watchers');
    
    final List<Watcher> watchers = [];
    
    for (final map in maps) {
      final keywords = map['keywords'] != null 
          ? List<String>.from(json.decode(map['keywords']))
          : <String>[];
      
      watchers.add(Watcher(
        id: map['id'],
        name: map['name'],
        keywords: keywords,
        isEnabled: map['is_enabled'] == 1,
        createdAt: DateTime.parse(map['created_at']),
        lastUsed: map['last_used'] != null 
            ? DateTime.parse(map['last_used']) 
            : null,
      ));
    }
    
    return watchers;
  }

  /// Get a specific watcher by ID
  static Future<Watcher?> getWatcher(String id) async {
    final db = await SecureDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'watchers',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    final keywords = map['keywords'] != null 
        ? List<String>.from(json.decode(map['keywords']))
        : <String>[];
    
    return Watcher(
      id: map['id'],
      name: map['name'],
      keywords: keywords,
      isEnabled: map['is_enabled'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      lastUsed: map['last_used'] != null 
          ? DateTime.parse(map['last_used']) 
          : null,
    );
  }

  /// Update watcher
  static Future<void> updateWatcher(Watcher watcher) async {
    final db = await SecureDatabase.database;
    
    await db.update(
      'watchers',
      {
        'name': watcher.name,
        'keywords': json.encode(watcher.keywords),
        'is_enabled': watcher.isEnabled ? 1 : 0,
        'last_used': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [watcher.id],
    );
  }

  /// Delete a watcher
  static Future<void> deleteWatcher(String id) async {
    final db = await SecureDatabase.database;
    await db.delete(
      'watchers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggle watcher enabled/disabled
  static Future<void> toggleWatcher(String id, bool enabled) async {
    final watcher = await getWatcher(id);
    if (watcher == null) return;
    
    final updatedWatcher = watcher.copyWith(isEnabled: enabled);
    await updateWatcher(updatedWatcher);
  }

  /// Get enabled watchers
  static Future<List<Watcher>> getEnabledWatchers() async {
    final watchers = await loadWatchers();
    return watchers.where((watcher) => watcher.isEnabled).toList();
  }

  /// Get default watchers for initial setup
  static List<Watcher> getDefaultWatchers() {
    return [
      Watcher(
        id: 'default_global',
        name: 'Global',
        keywords: [],
        createdAt: DateTime.now(),
      ),
      Watcher(
        id: 'default_cars',
        name: 'Cars',
        keywords: ['#musclecars', '#racing', '#cars', '#automotive', '#supercar'],
        createdAt: DateTime.now(),
      ),
      Watcher(
        id: 'default_crypto',
        name: 'Crypto',
        keywords: ['#bitcoin', '#crypto', '#blockchain', '#defi', '#nft'],
        createdAt: DateTime.now(),
      ),
      Watcher(
        id: 'default_tech',
        name: 'Tech',
        keywords: ['#technology', '#programming', '#ai', '#software', '#startup'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Import default watchers
  static Future<void> importDefaultWatchers() async {
    final existingWatchers = await loadWatchers();
    final existingNames = existingWatchers.map((w) => w.name).toSet();
    
    for (final watcher in getDefaultWatchers()) {
      if (!existingNames.contains(watcher.name)) {
        await saveWatcher(watcher);
      }
    }
  }
} 