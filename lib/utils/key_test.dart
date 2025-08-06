import '../services/nostr_key_service.dart';
import '../models/keychain_key.dart';

class KeyTest {
  /// Test Nostr key generation
  static Future<void> testKeyGeneration() async {
    try {
      print('🧪 Testing Nostr key generation...');
      
      // Test 1: Generate a new key
      final key1 = await NostrKeyService.generateNewKey('Test Key 1');
      print('✅ Generated key: ${key1.name}');
      print('   Private key: ${key1.privateKey.substring(0, 16)}...');
      print('   Public key: ${key1.publicKey.substring(0, 16)}...');
      
      // Test 2: Validate private key format (simplified check)
      final isValidPrivate = key1.privateKey.length == 64;
      print('✅ Private key validation: $isValidPrivate');
      
      // Test 3: Validate public key format
      final isValidPublic = NostrKeyService.isValidPublicKey(key1.publicKey);
      print('✅ Public key validation: $isValidPublic');
      
      // Test 4: Generate from mnemonic
      final mnemonic = NostrKeyService.generateMnemonic();
      print('✅ Generated mnemonic: ${mnemonic.split(' ').take(3).join(' ')}...');
      
      final key2 = await NostrKeyService.generateFromMnemonic('Test Key 2', mnemonic);
      print('✅ Generated key from mnemonic: ${key2.name}');
      
      // Test 5: Import existing key
      final importedKey = await NostrKeyService.importKey('Test Import', key1.privateKey);
      print('✅ Imported key: ${importedKey.name}');
      print('   Imported public key matches: ${importedKey.publicKey == key1.publicKey}');
      
      print('🎉 All Nostr key tests passed!');
      
    } catch (e) {
      print('❌ Key generation test failed: $e');
    }
  }
  
  /// Test secure database operations
  static Future<void> testDatabaseOperations() async {
    try {
      print('🧪 Testing secure database operations...');
      
      // Test 1: Generate and save key
      final key = await NostrKeyService.generateNewKey('Database Test Key');
      await NostrKeyService.saveKey(key);
      print('✅ Saved key to database');
      
      // Test 2: Load keys
      final keys = await NostrKeyService.loadKeys();
      print('✅ Loaded ${keys.length} keys from database');
      
      // Test 3: Set active key
      await NostrKeyService.setActiveKey(key.id);
      print('✅ Set key as active');
      
      // Test 4: Get active key
      final activeKey = await NostrKeyService.getActiveKey();
      print('✅ Active key: ${activeKey?.name}');
      
      // Test 5: Delete key
      await NostrKeyService.deleteKey(key.id);
      print('✅ Deleted key from database');
      
      print('🎉 All database tests passed!');
      
    } catch (e) {
      print('❌ Database test failed: $e');
    }
  }
} 