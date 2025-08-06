import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/keychain_key.dart';
import '../models/user_preferences.dart';
import 'nostr_key_service.dart';

class AppCoordinator {
  static const String _activeKeyIdKey = 'active_key_id';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _encryptionKey = 'app_encryption_key';
  
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  static AppCoordinator? _instance;
  static AppCoordinator get instance {
    _instance ??= AppCoordinator._();
    return _instance!;
  }
  
  AppCoordinator._();
  
  // User preferences
  UserPreferences? _userPreferences;
  KeychainKey? _activeKey;
  bool _isInitialized = false;
  
  // Getters
  UserPreferences? get userPreferences => _userPreferences;
  KeychainKey? get activeKey => _activeKey;
  bool get isInitialized => _isInitialized;
  
  /// Initialize the app coordinator
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load user preferences
      await _loadUserPreferences();
      
      // Load active key
      await _loadActiveKey();
      
      _isInitialized = true;
    } catch (e) {
      // Handle initialization error gracefully
      print('AppCoordinator initialization error: $e');
      // Set default preferences if loading fails
      _userPreferences = UserPreferences.defaults();
      _activeKey = null;
      _isInitialized = true;
    }
  }
  
  /// Load user preferences from secure storage
  Future<void> _loadUserPreferences() async {
    try {
      final prefsJson = await _secureStorage.read(key: _userPreferencesKey);
      if (prefsJson != null) {
        final prefsMap = json.decode(prefsJson);
        _userPreferences = UserPreferences.fromJson(prefsMap);
      } else {
        // Create default preferences
        _userPreferences = UserPreferences.defaults();
        await _saveUserPreferences();
      }
    } catch (e) {
      // If loading fails, create default preferences
      print('Error loading user preferences: $e');
      _userPreferences = UserPreferences.defaults();
      // Don't try to save if there's an error, just use defaults
    }
  }
  
  /// Save user preferences to secure storage
  Future<void> _saveUserPreferences() async {
    if (_userPreferences != null) {
      try {
        final prefsJson = json.encode(_userPreferences!.toJson());
        await _secureStorage.write(key: _userPreferencesKey, value: prefsJson);
      } catch (e) {
        print('Error saving user preferences: $e');
        // Continue without saving if there's an error
      }
    }
  }
  
  /// Load active key from secure storage
  Future<void> _loadActiveKey() async {
    try {
      _activeKey = await NostrKeyService.getActiveKey();
    } catch (e) {
      // No active key found
      _activeKey = null;
    }
  }
  
  /// Set the active key
  Future<void> setActiveKey(KeychainKey key) async {
    _activeKey = key;
    await NostrKeyService.setActiveKey(key.id);
  }
  
  /// Clear the active key
  Future<void> clearActiveKey() async {
    _activeKey = null;
    await _secureStorage.delete(key: _activeKeyIdKey);
  }
  
  /// Update user preferences
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    _userPreferences = preferences;
    await _saveUserPreferences();
  }
  
  /// Update specific preference
  Future<void> updatePreference<T>(String key, T value) async {
    if (_userPreferences != null) {
      _userPreferences!.updatePreference(key, value);
      await _saveUserPreferences();
    }
  }
  
  /// Get a specific preference
  T? getPreference<T>(String key) {
    return _userPreferences?.getPreference<T>(key);
  }
  
  /// Clear all stored data (for logout)
  Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
      _userPreferences = UserPreferences.defaults();
      _activeKey = null;
      await _saveUserPreferences();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
  
  /// Check if user is logged in
  bool get isLoggedIn => _activeKey != null;
  
  /// Get user display name
  String get userDisplayName {
    if (_activeKey != null) {
      return _activeKey!.name;
    }
    return 'Guest';
  }
  
  /// Get user public key
  String? get userPublicKey {
    return _activeKey?.publicKey;
  }
  
  /// Get user private key (use with caution)
  String? get userPrivateKey {
    return _activeKey?.privateKey;
  }
  
  /// Validate current session
  bool get isSessionValid {
    return _isInitialized && _activeKey != null;
  }
  
  /// Logout user
  Future<void> logout() async {
    await clearActiveKey();
  }
  
  /// Get app theme
  String get theme {
    return _userPreferences?.theme ?? 'dark';
  }
  
  /// Get language
  String get language {
    return _userPreferences?.language ?? 'en';
  }
  
  /// Get notification settings
  bool get notificationsEnabled {
    return _userPreferences?.notificationsEnabled ?? true;
  }
  
  /// Get auto-connect setting
  bool get autoConnect {
    return _userPreferences?.autoConnect ?? false;
  }
  
  /// Get relay settings
  List<String> get defaultRelays {
    return _userPreferences?.defaultRelays ?? [];
  }
  
  /// Get privacy settings
  Map<String, dynamic> get privacySettings {
    return _userPreferences?.privacySettings ?? {};
  }
} 