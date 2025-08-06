import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/nostr_event.dart';
import '../models/relay.dart';
import '../models/watcher.dart';
import 'relay_service.dart';

class NostrService {
  static final Map<String, WebSocketChannel> _connections = {};
  static final StreamController<List<NostrEvent>> _eventsController = 
      StreamController<List<NostrEvent>>.broadcast();
  
  static Stream<List<NostrEvent>> get eventsStream => _eventsController.stream;

  /// Connect to all enabled relays
  static Future<void> connectToRelays() async {
    final relays = await RelayService.getEnabledRelays();
    
    for (final relay in relays) {
      await _connectToRelay(relay);
    }
  }

  /// Connect to a specific relay
  static Future<void> _connectToRelay(Relay relay) async {
    try {
      final channel = WebSocketChannel.connect(Uri.parse(relay.url));
      _connections[relay.id] = channel;
      
      // Subscribe to all text notes (kind 1)
      final subscription = {
        'id': 'sub_${relay.id}',
        'method': 'REQ',
        'params': [
          'sub_${relay.id}',
          {
            'kinds': [1],
            'limit': 100,
          }
        ]
      };
      
      channel.sink.add(jsonEncode(subscription));
      
      // Listen for events
      channel.stream.listen(
        (data) {
          _handleRelayMessage(data, relay);
        },
        onError: (error) {
          print('Error connecting to relay ${relay.url}: $error');
          _connections.remove(relay.id);
        },
        onDone: () {
          print('Connection closed for relay ${relay.url}');
          _connections.remove(relay.id);
        },
      );
      
      // Update relay status
      await RelayService.updateRelayStatus(relay.id, true);
      
    } catch (e) {
      print('Failed to connect to relay ${relay.url}: $e');
      await RelayService.updateRelayStatus(relay.id, false);
    }
  }

  /// Handle messages from relays
  static void _handleRelayMessage(dynamic data, Relay relay) {
    try {
      final message = jsonDecode(data);
      
      if (message is List && message.length >= 2) {
        final type = message[0];
        
        if (type == 'EVENT') {
          final eventData = message[2];
          if (eventData is Map) {
            final event = NostrEvent.fromJson(Map<String, dynamic>.from(eventData));
            _eventsController.add([event]);
          }
        }
      }
    } catch (e) {
      print('Error parsing relay message: $e');
    }
  }

  /// Fetch events for a specific watcher
  static Future<List<NostrEvent>> fetchEventsForWatcher(Watcher watcher) async {
    final events = <NostrEvent>[];
    final relays = await RelayService.getEnabledRelays();
    
    print('🔍 Fetching events for watcher: ${watcher.name}');
    print('🔍 Keywords: ${watcher.keywords}');
    print('🔍 Available relays: ${relays.length}');
    
    for (final relay in relays) {
      try {
        final relayEvents = await _fetchEventsFromRelay(relay, watcher.keywords);
        events.addAll(relayEvents);
      } catch (e) {
        print('❌ Error fetching events from relay ${relay.url}: $e');
      }
    }
    
    print('🔍 Total events found: ${events.length}');
    
    // Sort by creation time (newest first)
    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return events;
  }

  /// Fetch events from a specific relay
  static Future<List<NostrEvent>> _fetchEventsFromRelay(Relay relay, List<String> keywords) async {
    final events = <NostrEvent>[];
    
    print('🔌 Connecting to relay: ${relay.url}');
    
    try {
      final channel = WebSocketChannel.connect(Uri.parse(relay.url));
      
      print('✅ WebSocket connection established to ${relay.url}');
      
      // Create a completer to wait for response
      final completer = Completer<List<NostrEvent>>();
      final subscriptionId = 'fetch_${relay.id}_${DateTime.now().millisecondsSinceEpoch}';
      
      print('📡 Subscription ID: $subscriptionId');
      
      // Listen for events
      channel.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            
            if (message is List && message.length >= 2) {
              final type = message[0];
              
              if (type == 'EVENT') {
                final eventData = message[2];
                if (eventData is Map) {
                  final event = NostrEvent.fromJson(Map<String, dynamic>.from(eventData));
                  
                  // Debug: Show first few events to understand what we're getting
                  if (events.length < 3) {
                    print('📨 Event ${events.length + 1}: "${event.content.substring(0, event.content.length > 50 ? 50 : event.content.length)}..."');
                  }
                  
                  // Filter by keywords if provided
                  if (keywords.isEmpty || event.matchesWatcher(keywords)) {
                    if (keywords.isNotEmpty) {
                      print('✅ Event matches keywords!');
                    }
                    events.add(event);
                  }
                }
              } else if (type == 'EOSE') {
                // End of stored events
                completer.complete(events);
                channel.sink.close();
              }
            }
          } catch (e) {
            print('Error parsing relay message: $e');
          }
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          completer.completeError(error);
          channel.sink.close();
        },
        onDone: () {
          print('✅ WebSocket connection closed');
          if (!completer.isCompleted) {
            completer.complete(events);
          }
        },
      );
      
      // Send subscription request in Nostr format
      final Map<String, dynamic> filters = {
        'kinds': [1],
        'limit': 50, // Keep normal limit for app functionality
      };
      
      // For now, get all events and filter client-side
      // TODO: Implement proper hashtag filtering once we confirm the correct format
      
      final subscription = [
        'REQ',
        subscriptionId,
        filters,
      ];
      
      print('📤 Sending subscription request: ${jsonEncode(subscription)}');
      channel.sink.add(jsonEncode(subscription));
      
      // Wait for response with timeout
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          channel.sink.close();
          return events;
        },
      );
      
    } catch (e) {
      print('Error fetching events from relay ${relay.url}: $e');
      return events;
    }
  }

  /// Disconnect from all relays
  static void disconnect() {
    for (final channel in _connections.values) {
      channel.sink.close();
    }
    _connections.clear();
  }


} 