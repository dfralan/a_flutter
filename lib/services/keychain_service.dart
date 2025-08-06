import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../models/keychain_key.dart';
import 'nostr_key_service.dart';
import 'secure_database.dart';

class KeychainService {
  static const String _storageKey = 'keychain_keys';
  
  // Use secure database instead of in-memory storage
  
  // Generate a new key pair using Nostr key service
  static Future<KeychainKey> generateNewKey(String name) async {
    return await NostrKeyService.generateNewKey(name);
  }
  
  // Public key generation is now handled by NostrKeyService
  
  // Save a key to secure database
  static Future<void> saveKey(KeychainKey key) async {
    await NostrKeyService.saveKey(key);
  }
  
  // Load all keys from secure database
  static Future<List<KeychainKey>> loadKeys() async {
    return await NostrKeyService.loadKeys();
  }
  
  // Save all keys to secure database
  static Future<void> _saveKeys(List<KeychainKey> keys) async {
    // This method is no longer needed as we use the database directly
  }
  
  // Delete a key from secure database
  static Future<void> deleteKey(String keyId) async {
    await NostrKeyService.deleteKey(keyId);
  }
  
  // Set a key as active in secure database
  static Future<void> setActiveKey(String keyId) async {
    await NostrKeyService.setActiveKey(keyId);
  }
  
  // Get the currently active key from secure database
  static Future<KeychainKey?> getActiveKey() async {
    return await NostrKeyService.getActiveKey();
  }
  
  // Import a key from private key string using Nostr key service
  static Future<KeychainKey> importKey(String name, String privateKeyString) async {
    return await NostrKeyService.importKey(name, privateKeyString);
  }
} 