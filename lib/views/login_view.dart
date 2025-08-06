import 'package:flutter/material.dart';
import '../services/keychain_service.dart';
import '../models/keychain_key.dart';
import 'keychain_admin_view.dart';
import 'relay_admin_view.dart';
import 'watchers_admin_view.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  KeychainKey? _selectedKey;
  List<KeychainKey> _availableKeys = [];
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
      final activeKey = await KeychainService.getActiveKey();
      
      setState(() {
        _availableKeys = keys;
        _selectedKey = activeKey;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        await KeychainService.setActiveKey(newKey.id);
        await _loadKeys();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New key created and set as active!'),
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
        await KeychainService.setActiveKey(importedKey.id);
        await _loadKeys();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Key imported and set as active!'),
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

  Future<void> _login() async {
    if (_selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a key to continue'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to main app
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WatchersAdminView(),
                ),
              );
            },
            icon: const Icon(Icons.search),
            tooltip: 'Watchers Administrator',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RelayAdminView(),
                ),
              );
            },
            icon: const Icon(Icons.wifi),
            tooltip: 'Relay Administrator',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const KeychainAdminView(),
                ),
              ).then((_) => _loadKeys());
            },
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Keychain Administrator',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Choose a key to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Key selection
                  if (_availableKeys.isNotEmpty) ...[
                    const Text(
                      'Available Keys',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Expanded(
                      child: ListView.builder(
                        itemCount: _availableKeys.length,
                        itemBuilder: (context, index) {
                          final key = _availableKeys[index];
                          final isSelected = _selectedKey?.id == key.id;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF6366F1) 
                                    : const Color(0xFF374151),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF6366F1) 
                                      : const Color(0xFF374151),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.key,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                key.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'Created: ${_formatDate(key.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6366F1),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedKey = key;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
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
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  if (_availableKeys.isNotEmpty) ...[
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                  ],
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _createNewKey,
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Key'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF9CA3AF),
                            side: const BorderSide(color: Color(0xFF374151)),
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
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 