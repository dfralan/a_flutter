import 'package:flutter/material.dart';
import '../models/watcher.dart';
import '../services/watcher_service.dart';

class WatchersAdminView extends StatefulWidget {
  const WatchersAdminView({super.key});

  @override
  State<WatchersAdminView> createState() => _WatchersAdminViewState();
}

class _WatchersAdminViewState extends State<WatchersAdminView> {
  List<Watcher> _watchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchers();
  }

  Future<void> _loadWatchers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final watchers = await WatcherService.loadWatchers();
      setState(() {
        _watchers = watchers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createWatcher() async {
    final nameController = TextEditingController();
    final keywordsController = TextEditingController();
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Create New Watcher',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Watcher Name',
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
              controller: keywordsController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Keywords (one per line)',
                labelStyle: TextStyle(color: Color(0xFF9CA3AF)),
                hintText: '#cars\n#racing\n#automotive',
                hintStyle: TextStyle(color: Color(0xFF6B7280)),
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
              if (nameController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'keywords': keywordsController.text,
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final keywords = result['keywords']!
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .toList();
        
        await WatcherService.createWatcher(result['name']!, keywords);
        await _loadWatchers();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Watcher created successfully!'),
            backgroundColor: Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating watcher: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editWatcher(Watcher watcher) async {
    final nameController = TextEditingController(text: watcher.name);
    final keywordsController = TextEditingController(
      text: watcher.keywords.join('\n'),
    );
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Edit Watcher',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Watcher Name',
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
              controller: keywordsController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Keywords (one per line)',
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
              if (nameController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'keywords': keywordsController.text,
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final keywords = result['keywords']!
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .toList();
        
        final updatedWatcher = watcher.copyWith(
          name: result['name']!,
          keywords: keywords,
        );
        
        await WatcherService.updateWatcher(updatedWatcher);
        await _loadWatchers();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Watcher updated successfully!'),
            backgroundColor: Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating watcher: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteWatcher(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Watcher',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this watcher?',
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
        await WatcherService.deleteWatcher(id);
        await _loadWatchers();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Watcher deleted successfully!'),
            backgroundColor: Color(0xFF32CD32),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting watcher: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleWatcher(String id, bool enabled) async {
    try {
      await WatcherService.toggleWatcher(id, enabled);
      await _loadWatchers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling watcher: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importDefaultWatchers() async {
    try {
      await WatcherService.importDefaultWatchers();
      await _loadWatchers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default watchers imported successfully!'),
          backgroundColor: Color(0xFF32CD32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing default watchers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Watchers Administrator'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _importDefaultWatchers,
            icon: const Icon(Icons.download),
            tooltip: 'Import Default Watchers',
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Text(
                    'Interest Groups',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create watchers to filter events by keywords',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Create button
                  ElevatedButton.icon(
                    onPressed: _createWatcher,
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Watcher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Watchers list
                  Expanded(
                    child: _watchers.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 64,
                                  color: Color(0xFF6366F1),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No watchers yet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Create your first watcher to start filtering events',
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _watchers.length,
                            itemBuilder: (context, index) {
                              final watcher = _watchers[index];
                              return _buildWatcherCard(watcher);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWatcherCard(Watcher watcher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      watcher.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${watcher.keywords.length} keywords',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: watcher.isEnabled,
                onChanged: (value) => _toggleWatcher(watcher.id, value),
                activeColor: const Color(0xFF6366F1),
              ),
            ],
          ),
          
          if (watcher.keywords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: watcher.keywords.map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    keyword,
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _editWatcher(watcher),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _deleteWatcher(watcher.id),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 