import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/floating_nav_bar.dart';
import '../models/watcher.dart';
import '../models/nostr_event.dart';
import '../services/watcher_service.dart';
import '../services/nostr_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  Watcher? _selectedWatcher;
  List<Watcher> _watchers = [];
  List<NostrEvent> _events = [];
  bool _isLoadingEvents = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadWatchers();
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWatchers() async {
    try {
      final watchers = await WatcherService.loadWatchers();
      setState(() {
        _watchers = watchers;
        if (_selectedWatcher == null && watchers.isNotEmpty) {
          _selectedWatcher = watchers.first;
          _loadEvents();
        }
      });
    } catch (e) {
      print('Error loading watchers: $e');
    }
  }

  Future<void> _loadEvents() async {
    if (_selectedWatcher == null) return;
    
    setState(() {
      _isLoadingEvents = true;
    });

    try {
      final events = await NostrService.fetchEventsForWatcher(_selectedWatcher!);
      setState(() {
        _events = events;
        _isLoadingEvents = false;
      });
    } catch (e) {
      // Handle error - no events found
      print('Error fetching events: $e');
      setState(() {
        _events = [];
        _isLoadingEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Main content area
          _buildCurrentView(),
          
          // Floating navigation bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          
          // Floating create button
          Positioned(
            bottom: 100,
            right: 20,
            child: _buildCreateButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentIndex) {
      case 0:
        return _buildFeedView();
      case 1:
        return _buildMessagesView();
      case 2:
        return _buildProfileView();
      default:
        return _buildFeedView();
    }
  }

  Widget _buildFeedView() {
    return CustomScrollView(
      slivers: [
        // Custom app bar with search and interest filters
        SliverAppBar(
          expandedHeight: 140,
          floating: true,
          pinned: true,
          backgroundColor: const Color(0xFF0A0A0A),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A1A),
                    Color(0xFF0A0A0A),
                  ],
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2A2A2A),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Watcher filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _watchers.map((watcher) {
                      final isSelected = _selectedWatcher?.id == watcher.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedWatcher = watcher;
                            });
                            
                            // Debounce the event loading to prevent rapid requests
                            _debounceTimer?.cancel();
                            _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                              _loadEvents();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF6366F1)
                                    : const Color(0xFF2A2A2A),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              watcher.displayName,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
        
        // Feed content
        _isLoadingEvents
            ? const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                  ),
                ),
              )
            : _events.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Color(0xFF6366F1),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No events found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your watcher keywords',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildFeedItem(_events[index]);
                      },
                      childCount: _events.length,
                    ),
                  ),
      ],
    );
  }

  Widget _buildFeedItem(NostrEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with watcher info
          Row(
            children: [
              Text(
                _selectedWatcher?.name ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Relay indicators
              Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CA3AF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '+3 relays',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.more_vert,
                    color: Color(0xFF9CA3AF),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Author info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF6366F1),
                child: Text(
                  event.authorDisplayName.substring(1, 3),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.authorDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'nostr.ar',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'posted on nostr.ar and +2 relays',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Post content
          Text(
            event.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          
          // Hashtags
          if (event.hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: event.hashtags.map((hashtag) {
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
                    hashtag,
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
          
          const SizedBox(height: 16),
          
          // Floating action bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF6366F1),
                      child: Text(
                        'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF2A2A2A),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFF9CA3AF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.grid_view,
                  color: Color(0xFF9CA3AF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.more_vert,
                  color: Color(0xFF9CA3AF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.edit,
                  color: Color(0xFF9CA3AF),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.edit,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildMessagesView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 64,
            color: Color(0xFF6366F1),
          ),
          SizedBox(height: 16),
          Text(
            'Messages',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Direct messages coming soon!',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Color(0xFF6366F1),
          ),
          SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'User profile coming soon!',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
} 