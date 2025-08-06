import 'package:flutter/material.dart';
import '../models/keychain_key.dart';
import '../services/keychain_service.dart';
import '../widgets/key_item_widget.dart';

class KeychainAdminView extends StatefulWidget {
  const KeychainAdminView({super.key});

  @override
  State<KeychainAdminView> createState() => _KeychainAdminViewState();
}

class _KeychainAdminViewState extends State<KeychainAdminView> {
  List<KeychainKey> _keys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final keys = await KeychainService.loadKeys();
      setState(() {
        _keys = keys;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading keys: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createNewKey() async {
    final nameController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Create New Key',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Key Name',
            labelStyle: TextStyle(color: Color(0xFF9CA3AF)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF374151)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.of(context).pop(nameController.text);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final newKey = await KeychainService.generateNewKey(result);
        await KeychainService.saveKey(newKey);
        await _loadKeys();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New key created successfully!'),
            backgroundColor: Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importKey() async {
    final nameController = TextEditingController();
    final privateKeyController = TextEditingController();
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Import Existing Key',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Key Name',
                labelStyle: TextStyle(color: Color(0xFF9CA3AF)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: privateKeyController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Private Key',
                labelStyle: TextStyle(color: Color(0xFF9CA3AF)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  privateKeyController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'privateKey': privateKeyController.text,
                });
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final importedKey = await KeychainService.importKey(
          result['name']!,
          result['privateKey']!,
        );
        await KeychainService.saveKey(importedKey);
        await _loadKeys();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Key imported successfully!'),
            backgroundColor: Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setActiveKey(String keyId) async {
    try {
      await KeychainService.setActiveKey(keyId);
      await _loadKeys();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Active key updated!'),
          backgroundColor: Color(0xFF32CD32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error setting active key: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteKey(String keyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Key',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this key? This action cannot be undone.',
          style: TextStyle(color: Color(0xFFD1D5DB)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await KeychainService.deleteKey(keyId);
        await _loadKeys();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Key deleted successfully!'),
            backgroundColor: Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Keychain Administrator'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            )
          : Column(
              children: [
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _createNewKey,
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Key'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importKey,
                          icon: const Icon(Icons.download),
                          label: const Text('Import Key'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF9CA3AF),
                            side: const BorderSide(color: Color(0xFF374151)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Keys list
                Expanded(
                  child: _keys.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.key,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No keys found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create a new key or import an existing one to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _keys.length,
                          itemBuilder: (context, index) {
                            final key = _keys[index];
                                                         return KeyItemWidget(
                               keychainKey: key,
                               onSetActive: () => _setActiveKey(key.id),
                               onDelete: () => _deleteKey(key.id),
                             );
                          },
                        ),
                ),
              ],
            ),
    );
  }
} 