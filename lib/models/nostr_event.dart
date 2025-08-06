class NostrEvent {
  final String id;
  final String pubkey;
  final int createdAt;
  final int kind;
  final List<List<String>> tags;
  final String content;
  final String sig;

  NostrEvent({
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    required this.tags,
    required this.content,
    required this.sig,
  });

  NostrEvent copyWith({
    String? id,
    String? pubkey,
    int? createdAt,
    int? kind,
    List<List<String>>? tags,
    String? content,
    String? sig,
  }) {
    return NostrEvent(
      id: id ?? this.id,
      pubkey: pubkey ?? this.pubkey,
      createdAt: createdAt ?? this.createdAt,
      kind: kind ?? this.kind,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      sig: sig ?? this.sig,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pubkey': pubkey,
      'created_at': createdAt,
      'kind': kind,
      'tags': tags,
      'content': content,
      'sig': sig,
    };
  }

  factory NostrEvent.fromJson(Map<String, dynamic> json) {
    return NostrEvent(
      id: json['id'],
      pubkey: json['pubkey'],
      createdAt: json['created_at'],
      kind: json['kind'],
      tags: List<List<String>>.from(
        json['tags'].map((tag) => List<String>.from(tag)),
      ),
      content: json['content'],
      sig: json['sig'],
    );
  }

  /// Get author's display name (first 8 characters of pubkey)
  String get authorDisplayName {
    return '@${pubkey.substring(0, 8)}...';
  }

  /// Get author's full pubkey
  String get authorPubkey {
    return pubkey;
  }

  /// Get creation date as DateTime
  DateTime get createdAtDateTime {
    return DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
  }

  /// Get hashtags from content
  List<String> get hashtags {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(content).map((match) => match.group(0)!).toList();
  }

  /// Get mentions from content
  List<String> get mentions {
    final regex = RegExp(r'@\w+');
    return regex.allMatches(content).map((match) => match.group(0)!).toList();
  }

  /// Check if event matches any watcher keywords
  bool matchesWatcher(List<String> keywords) {
    if (keywords.isEmpty) return true;
    
    final lowerContent = content.toLowerCase();
    
    // Get hashtags from tags (tags with type "t")
    final hashtags = tags
        .where((tag) => tag.isNotEmpty && tag[0] == 't')
        .map((tag) => tag.length > 1 ? tag[1].toLowerCase() : '')
        .where((tag) => tag.isNotEmpty)
        .toList();
    
    return keywords.any((keyword) {
      final lowerKeyword = keyword.toLowerCase();
      
      // Check if keyword appears in content
      if (lowerContent.contains(lowerKeyword)) {
        return true;
      }
      
      // Check if keyword appears in hashtags (with or without #)
      final keywordWithoutHash = lowerKeyword.startsWith('#') 
          ? lowerKeyword.substring(1) 
          : lowerKeyword;
      
      return hashtags.any((hashtag) {
        final hashtagWithoutHash = hashtag.startsWith('#') 
            ? hashtag.substring(1) 
            : hashtag;
        return hashtagWithoutHash.contains(keywordWithoutHash) || 
               keywordWithoutHash.contains(hashtagWithoutHash);
      });
    });
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAtDateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
} 