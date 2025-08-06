import 'package:flutter/material.dart';
import '../models/keychain_key.dart';

class KeyItemWidget extends StatelessWidget {
  final KeychainKey keychainKey;
  final VoidCallback onSetActive;
  final VoidCallback onDelete;

  const KeyItemWidget({
    super.key,
    required this.keychainKey,
    required this.onSetActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: keychainKey.isActive ? const Color(0xFF6366F1) : const Color(0xFF374151),
          width: keychainKey.isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: keychainKey.isActive 
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            keychainKey.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (keychainKey.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${_formatDate(keychainKey.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF9CA3AF),
                  ),
                  color: const Color(0xFF1A1A1A),
                  itemBuilder: (context) => [
                    if (!keychainKey.isActive)
                      const PopupMenuItem(
                        value: 'set_active',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Set as Active',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'set_active':
                        onSetActive();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Public Key:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _truncateKey(keychainKey.publicKey),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFD1D5DB),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _truncateKey(String key) {
    if (key.length <= 20) return key;
    return '${key.substring(0, 10)}...${key.substring(key.length - 10)}';
  }
} 