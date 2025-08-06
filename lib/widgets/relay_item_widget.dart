import 'package:flutter/material.dart';
import '../models/relay.dart';

class RelayItemWidget extends StatelessWidget {
  final Relay relay;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTest;

  const RelayItemWidget({
    super.key,
    required this.relay,
    required this.onToggle,
    required this.onDelete,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: relay.isConnected 
              ? const Color(0xFF32CD32) 
              : relay.isEnabled 
                  ? const Color(0xFF6366F1) 
                  : const Color(0xFF374151),
          width: relay.isConnected ? 2 : 1,
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
                    color: relay.isConnected 
                        ? const Color(0xFF32CD32) 
                        : relay.isEnabled 
                            ? const Color(0xFF6366F1) 
                            : const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getRelayIcon(),
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
                          Expanded(
                            child: Text(
                              relay.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (relay.isConnected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF32CD32),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Connected',
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
                        relay.url,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        relay.statusDescription,
                        style: TextStyle(
                          fontSize: 10,
                          color: relay.isEnabled 
                              ? const Color(0xFF9CA3AF) 
                              : const Color(0xFF6B7280),
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
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            relay.isEnabled ? Icons.pause : Icons.play_arrow,
                            color: relay.isEnabled 
                                ? Colors.orange 
                                : const Color(0xFF6366F1),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            relay.isEnabled ? 'Disable' : 'Enable',
                            style: TextStyle(
                              color: relay.isEnabled 
                                  ? Colors.orange 
                                  : const Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'test',
                      child: Row(
                        children: [
                          Icon(
                            Icons.wifi_tethering,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Test Connection',
                            style: TextStyle(color: Color(0xFF6366F1)),
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
                      case 'toggle':
                        onToggle();
                        break;
                      case 'test':
                        onTest();
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
            
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Connections',
                    relay.connectionCount.toString(),
                    Icons.link,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Success',
                    relay.successCount.toString(),
                    Icons.check_circle,
                    color: const Color(0xFF32CD32),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Failures',
                    relay.failureCount.toString(),
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Success Rate',
                    '${relay.successRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            
            // Metadata
            if (relay.metadata.isNotEmpty) ...[
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
                    if (relay.description != null) ...[
                      Text(
                        'Description:',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        relay.description!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (relay.location != null) ...[
                      Text(
                        'Location: ${relay.location}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (relay.isPaid) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Paid Relay',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? const Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  IconData _getRelayIcon() {
    if (relay.isConnected) {
      return Icons.wifi;
    } else if (relay.isEnabled) {
      return Icons.wifi_off;
    } else {
      return Icons.block;
    }
  }
} 