import 'package:flutter/material.dart';
import '../models/relay.dart';
import '../services/relay_service.dart';
import '../widgets/relay_item_widget.dart';

class RelayAdminView extends StatefulWidget {
  const RelayAdminView({super.key});

  @override
  State<RelayAdminView> createState() => _RelayAdminViewState();
}

class _RelayAdminViewState extends State<RelayAdminView> {
  List<Relay> _relays = [];
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadRelays();
  }

  Future<void> _loadRelays() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final relays = await RelayService.loadRelays();
      final stats = await RelayService.getRelayStats();
      
      setState(() {
        _relays = relays;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading relays: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addRelay() async {
    final urlController = TextEditingController();
    final nameController = TextEditingController();
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Add New Relay',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Relay URL (wss://...)',
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
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Display Name (optional)',
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
              if (urlController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  'url': urlController.text,
                  'name': nameController.text.isNotEmpty 
                      ? nameController.text 
                      : '',
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final name = result['name']!.isNotEmpty 
            ? result['name']! 
            : _extractDomain(result['url']!);
        
        final relay = await RelayService.createRelay(result['url']!, name);
        await _loadRelays();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relay added successfully!'),
            backgroundColor: Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding relay: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importDefaultRelays() async {
    try {
      final defaultRelays = RelayService.getDefaultRelays();
      final existingRelays = await RelayService.loadRelays();
      final existingUrls = existingRelays.map((r) => r.url).toSet();
      
      int importedCount = 0;
      for (final relay in defaultRelays) {
        if (!existingUrls.contains(relay.url)) {
          await RelayService.saveRelay(relay);
          importedCount++;
        }
      }
      
      await _loadRelays();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported $importedCount new default relays!'),
          backgroundColor: const Color(0xFF32CD32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing default relays: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importRelays() async {
    final urlController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Import Relays',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter relay URLs (one per line):',
              style: TextStyle(color: Color(0xFFD1D5DB)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Relay URLs',
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
              if (urlController.text.isNotEmpty) {
                Navigator.of(context).pop(urlController.text);
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final urls = result.split('\n').where((url) => url.trim().isNotEmpty).toList();
        final importedRelays = await RelayService.importRelays(urls);
        
        await _loadRelays();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported ${importedRelays.length} relays successfully!'),
            backgroundColor: const Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing relays: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleRelay(String id) async {
    try {
      final relay = _relays.firstWhere((r) => r.id == id);
      await RelayService.toggleRelay(id, !relay.isEnabled);
      await _loadRelays();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Relay ${relay.isEnabled ? 'disabled' : 'enabled'} successfully!'),
          backgroundColor: const Color(0xFF32CD32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling relay: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testRelay(String id) async {
    try {
      final relay = _relays.firstWhere((r) => r.id == id);
      final isConnected = await RelayService.testRelayConnection(relay.url);
      
      await RelayService.updateRelayStatus(id, isConnected);
      await RelayService.updateRelayStats(id, isConnected);
      await _loadRelays();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isConnected 
              ? 'Relay connection test successful!' 
              : 'Relay connection test failed'),
          backgroundColor: isConnected 
              ? const Color(0xFF32CD32) 
              : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing relay: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteRelay(String id) async {
    final relay = _relays.firstWhere((r) => r.id == id);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Relay',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${relay.name}"? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFFD1D5DB)),
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
        await RelayService.deleteRelay(id);
        await _loadRelays();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relay deleted successfully!'),
            backgroundColor: Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting relay: $e'),
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
        title: const Text('Relay Administrator'),
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
                // Statistics header
                if (_stats != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            _stats!['totalRelays'].toString(),
                            Icons.wifi,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            'Enabled',
                            _stats!['enabledRelays'].toString(),
                            Icons.check_circle,
                            color: const Color(0xFF32CD32),
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            'Connected',
                            _stats!['connectedRelays'].toString(),
                            Icons.link,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            'Success Rate',
                            '${_stats!['successRate'].toStringAsFixed(1)}%',
                            Icons.trending_up,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addRelay,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Relay'),
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
                          onPressed: _importDefaultRelays,
                          icon: const Icon(Icons.download),
                          label: const Text('Import Defaults'),
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
                
                // Relays list
                Expanded(
                  child: _relays.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No relays found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add relays or import default ones to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _importDefaultRelays,
                                icon: const Icon(Icons.download),
                                label: const Text('Import Default Relays'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _relays.length,
                          itemBuilder: (context, index) {
                            final relay = _relays[index];
                            return RelayItemWidget(
                              relay: relay,
                              onToggle: () => _toggleRelay(relay.id),
                              onDelete: () => _deleteRelay(relay.id),
                              onTest: () => _testRelay(relay.id),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color ?? const Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  /// Extract domain from URL
  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }
} 