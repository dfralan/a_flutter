import 'dart:convert';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/keychain_key.dart';

class SecureDatabase {
  static const String _databaseName = 'nostr_keys.db';
  static const int _databaseVersion = 3;
  
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  static Database? _database;
  
  /// Get the database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Keys table
    await db.execute('''
      CREATE TABLE keys (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        private_key TEXT NOT NULL,
        public_key TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 0,
        encrypted INTEGER DEFAULT 1
      )
    ''');
    
    // User data table
    await db.execute('''
      CREATE TABLE user_data (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        encrypted INTEGER DEFAULT 1
      )
    ''');
    
    // Relay connections table
    await db.execute('''
      CREATE TABLE relay_connections (
        id TEXT PRIMARY KEY,
        url TEXT NOT NULL,
        name TEXT,
        is_enabled INTEGER DEFAULT 1,
        is_connected INTEGER DEFAULT 0,
        last_connected TEXT,
        connection_count INTEGER DEFAULT 0,
        success_count INTEGER DEFAULT 0,
        failure_count INTEGER DEFAULT 0,
        metadata TEXT DEFAULT '{}',
        created_at TEXT NOT NULL,
        last_used TEXT
      )
    ''');
    
    // Messages table (for local storage)
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        author TEXT NOT NULL,
        created_at TEXT NOT NULL,
        encrypted INTEGER DEFAULT 1,
        is_deleted INTEGER DEFAULT 0
      )
    ''');
    
    // Watchers table
    await db.execute('''
      CREATE TABLE watchers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        keywords TEXT DEFAULT '[]',
        is_enabled INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        last_used TEXT
      )
    ''');
  }
  
  /// Upgrade database
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add missing columns to relay_connections table
      await db.execute('ALTER TABLE relay_connections ADD COLUMN is_connected INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE relay_connections ADD COLUMN success_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE relay_connections ADD COLUMN failure_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE relay_connections ADD COLUMN metadata TEXT DEFAULT "{}"');
      await db.execute('ALTER TABLE relay_connections ADD COLUMN created_at TEXT');
      await db.execute('ALTER TABLE relay_connections ADD COLUMN last_used TEXT');
      
      // Update existing records to have created_at timestamp
      await db.execute('UPDATE relay_connections SET created_at = datetime("now") WHERE created_at IS NULL');
    }
    
    if (oldVersion < 3) {
      // Add watchers table if it doesn't exist
      try {
        await db.execute('''
          CREATE TABLE watchers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            keywords TEXT DEFAULT '[]',
            is_enabled INTEGER DEFAULT 1,
            created_at TEXT NOT NULL,
            last_used TEXT
          )
        ''');
      } catch (e) {
        // Table might already exist, ignore error
        print('Watchers table creation error (might already exist): $e');
      }
    }
  }
  
  /// Encrypt sensitive data
  static Future<String> _encryptData(String data) async {
    // In a real implementation, you'd use proper encryption
    // For now, we'll use base64 encoding as a placeholder
    return base64.encode(utf8.encode(data));
  }
  
  /// Decrypt sensitive data
  static Future<String> _decryptData(String encryptedData) async {
    // In a real implementation, you'd use proper decryption
    // For now, we'll use base64 decoding as a placeholder
    return utf8.decode(base64.decode(encryptedData));
  }
  
  /// Save a key to the database
  static Future<void> saveKey(KeychainKey key) async {
    final db = await database;
    
    final encryptedPrivateKey = await _encryptData(key.privateKey);
    final encryptedPublicKey = await _encryptData(key.publicKey);
    
    await db.insert(
      'keys',
      {
        'id': key.id,
        'name': key.name,
        'private_key': encryptedPrivateKey,
        'public_key': encryptedPublicKey,
        'created_at': key.createdAt.toIso8601String(),
        'is_active': key.isActive ? 1 : 0,
        'encrypted': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Load all keys from the database
  static Future<List<KeychainKey>> loadKeys() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('keys');
    
    final List<KeychainKey> keys = [];
    
    for (final map in maps) {
      final decryptedPrivateKey = await _decryptData(map['private_key']);
      final decryptedPublicKey = await _decryptData(map['public_key']);
      
      keys.add(KeychainKey(
        id: map['id'],
        name: map['name'],
        privateKey: decryptedPrivateKey,
        publicKey: decryptedPublicKey,
        createdAt: DateTime.parse(map['created_at']),
        isActive: map['is_active'] == 1,
      ));
    }
    
    return keys;
  }
  
  /// Get a specific key by ID
  static Future<KeychainKey?> getKey(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'keys',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    final decryptedPrivateKey = await _decryptData(map['private_key']);
    final decryptedPublicKey = await _decryptData(map['public_key']);
    
    return KeychainKey(
      id: map['id'],
      name: map['name'],
      privateKey: decryptedPrivateKey,
      publicKey: decryptedPublicKey,
      createdAt: DateTime.parse(map['created_at']),
      isActive: map['is_active'] == 1,
    );
  }
  
  /// Delete a key from the database
  static Future<void> deleteKey(String id) async {
    final db = await database;
    await db.delete(
      'keys',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Set a key as active
  static Future<void> setActiveKey(String id) async {
    final db = await database;
    
    // First, set all keys as inactive
    await db.update(
      'keys',
      {'is_active': 0},
    );
    
    // Then, set the specified key as active
    await db.update(
      'keys',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Get the active key
  static Future<KeychainKey?> getActiveKey() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'keys',
      where: 'is_active = ?',
      whereArgs: [1],
    );
    
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    final decryptedPrivateKey = await _decryptData(map['private_key']);
    final decryptedPublicKey = await _decryptData(map['public_key']);
    
    return KeychainKey(
      id: map['id'],
      name: map['name'],
      privateKey: decryptedPrivateKey,
      publicKey: decryptedPublicKey,
      createdAt: DateTime.parse(map['created_at']),
      isActive: true,
    );
  }
  
  /// Save user data
  static Future<void> saveUserData(String key, String value) async {
    final db = await database;
    final encryptedValue = await _encryptData(value);
    
    await db.insert(
      'user_data',
      {
        'key': key,
        'value': encryptedValue,
        'encrypted': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get user data
  static Future<String?> getUserData(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_data',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (maps.isEmpty) return null;
    
    final encryptedValue = maps.first['value'];
    return await _decryptData(encryptedValue);
  }
  
  /// Clear all data
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('keys');
    await db.delete('user_data');
    await db.delete('relay_connections');
    await db.delete('messages');
    await db.delete('watchers');
  }
  
  /// Force database recreation (for development/testing)
  static Future<void> recreateDatabase() async {
    await close();
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    // Delete the database file
    try {
      await deleteDatabase(path);
    } catch (e) {
      print('Error deleting database: $e');
    }
    
    // Reset the database instance
    _database = null;
  }
  
  /// Close the database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
} 