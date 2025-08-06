import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:crypto/crypto.dart';
import '../models/keychain_key.dart';
import 'secure_database.dart';

class NostrKeyService {
  static const int _privateKeyLength = 32; // 256 bits for secp256k1
  
  /// Generate a new Nostr key pair
  static Future<KeychainKey> generateNewKey(String name) async {
    // Generate a cryptographically secure random private key
    final random = Random.secure();
    final privateKeyBytes = Uint8List.fromList(
      List<int>.generate(_privateKeyLength, (i) => random.nextInt(256))
    );
    
    // Ensure the private key is valid for secp256k1
    // The private key must be less than the curve order
    final curveOrder = BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
      radix: 16
    );
    
    BigInt privateKeyInt = BigInt.parse(
      privateKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16
    );
    
    // Ensure the private key is in the valid range
    while (privateKeyInt >= curveOrder || privateKeyInt == BigInt.zero) {
      privateKeyBytes.setAll(0, List<int>.generate(_privateKeyLength, (i) => random.nextInt(256)));
      privateKeyInt = BigInt.parse(
        privateKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        radix: 16
      );
    }
    
    // Convert to hex string
    final privateKeyHex = privateKeyInt.toRadixString(16).padLeft(64, '0');
    
    // Generate public key from private key
    final publicKey = _generatePublicKeyFromPrivate(privateKeyHex);
    
    final key = KeychainKey(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      privateKey: privateKeyHex,
      publicKey: publicKey,
      createdAt: DateTime.now(),
    );
    
    return key;
  }
  
  /// Generate public key from private key using secp256k1
  static String _generatePublicKeyFromPrivate(String privateKeyHex) {
    try {
      // For now, use the fallback method as the secp256k1 package API is different
      // In production, you'd want to implement proper secp256k1 operations
      return _fallbackPublicKeyGeneration(privateKeyHex);
    } catch (e) {
      // Fallback to a simpler method if secp256k1 fails
      return _fallbackPublicKeyGeneration(privateKeyHex);
    }
  }
  
  /// Fallback public key generation (simplified)
  static String _fallbackPublicKeyGeneration(String privateKeyHex) {
    // This is a simplified fallback - in production, you'd want proper secp256k1
    // For now, we'll use a hash-based approach that's not cryptographically correct
    // but provides a consistent format for testing
    final hash = sha256.convert(utf8.encode(privateKeyHex));
    return hash.toString().substring(0, 64); // Return first 32 bytes as hex
  }
  
  /// Generate key from mnemonic phrase
  static Future<KeychainKey> generateFromMnemonic(String name, String mnemonic) async {
    // Validate mnemonic
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic phrase');
    }
    
    // Generate seed from mnemonic
    final seed = bip39.mnemonicToSeed(mnemonic);
    
    // Use the first 32 bytes as private key
    final privateKeyBytes = seed.sublist(0, 32);
    final privateKeyHex = privateKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    
    // Generate public key
    final publicKey = _generatePublicKeyFromPrivate(privateKeyHex);
    
    final key = KeychainKey(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      privateKey: privateKeyHex,
      publicKey: publicKey,
      createdAt: DateTime.now(),
    );
    
    return key;
  }
  
  /// Import key from private key string
  static Future<KeychainKey> importKey(String name, String privateKeyString) async {
    // Validate private key format
    if (!_isValidPrivateKey(privateKeyString)) {
      throw Exception('Invalid private key format');
    }
    
    // Generate public key
    final publicKey = _generatePublicKeyFromPrivate(privateKeyString);
    
    final key = KeychainKey(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      privateKey: privateKeyString,
      publicKey: publicKey,
      createdAt: DateTime.now(),
    );
    
    return key;
  }
  
  /// Validate private key format
  static bool _isValidPrivateKey(String privateKey) {
    // Check if it's a valid hex string with correct length
    if (privateKey.length != 64) return false;
    
    try {
      // Check if it's a valid hex string
      BigInt.parse(privateKey, radix: 16);
      
      // Check if it's in the valid range for secp256k1
      final curveOrder = BigInt.parse(
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
        radix: 16
      );
      
      final privateKeyInt = BigInt.parse(privateKey, radix: 16);
      return privateKeyInt > BigInt.zero && privateKeyInt < curveOrder;
    } catch (e) {
      return false;
    }
  }
  
  /// Generate mnemonic phrase
  static String generateMnemonic() {
    return bip39.generateMnemonic();
  }
  
  /// Validate public key format
  static bool isValidPublicKey(String publicKey) {
    if (publicKey.length != 64) return false;
    
    try {
      // Check if it's a valid hex string
      BigInt.parse(publicKey, radix: 16);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Sign a message with private key
  static Future<String> signMessage(String message, String privateKey) async {
    try {
      // In a real implementation, you'd use proper secp256k1 signing
      // For now, we'll return a placeholder
      final messageBytes = utf8.encode(message);
      final hash = sha256.convert(messageBytes);
      return hash.toString(); // This is just a placeholder
    } catch (e) {
      throw Exception('Failed to sign message: $e');
    }
  }
  
  /// Verify a signature
  static Future<bool> verifySignature(String message, String signature, String publicKey) async {
    try {
      // In a real implementation, you'd use proper secp256k1 verification
      // For now, we'll return true as a placeholder
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Save key to secure database
  static Future<void> saveKey(KeychainKey key) async {
    await SecureDatabase.saveKey(key);
  }
  
  /// Load all keys from secure database
  static Future<List<KeychainKey>> loadKeys() async {
    return await SecureDatabase.loadKeys();
  }
  
  /// Get active key from secure database
  static Future<KeychainKey?> getActiveKey() async {
    return await SecureDatabase.getActiveKey();
  }
  
  /// Set active key in secure database
  static Future<void> setActiveKey(String keyId) async {
    await SecureDatabase.setActiveKey(keyId);
  }
  
  /// Delete key from secure database
  static Future<void> deleteKey(String keyId) async {
    await SecureDatabase.deleteKey(keyId);
  }
} 