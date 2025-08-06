import 'package:flutter/material.dart';
import '../models/keychain_key.dart';
import '../services/keychain_service.dart';
import '../views/keychain_admin_view.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  List<KeychainKey> _keys = [];
  KeychainKey? _activeKey;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    try {
      final keys = await KeychainService.loadKeys();
      final activeKey = await KeychainService.getActiveKey();
      
      setState(() {
        _keys = keys;
        _activeKey = activeKey;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF374151),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF87CEEB), Color(0xFF32CD32), Color(0xFFFFFACD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.key,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Keychain',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const KeychainAdminView(),
                      ),
                    ).then((_) => _loadKeys());
                  },
                  icon: const Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  tooltip: 'Keychain Administrator',
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
                          size: 48,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No keys',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create or import keys to get started',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _keys.length,
                    itemBuilder: (context, index) {
                      final key = _keys[index];
                      final isActive = _activeKey?.id == key.id;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? const Color(0xFF6366F1) 
                                  : const Color(0xFF374151),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.key,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          title: Text(
                            key.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive ? Colors.white : const Color(0xFFD1D5DB),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: isActive ? const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                            ),
                          ) : null,
                          onTap: () {
                            // TODO: Switch to this key
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Switched to key: ${key.name}'),
                                backgroundColor: const Color(0xFF6366F1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFF374151),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                if (_activeKey != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeKey!.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Active Key',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const KeychainAdminView(),
                            ),
                          ).then((_) => _loadKeys());
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Key'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9CA3AF),
                          side: const BorderSide(color: Color(0xFF374151)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 