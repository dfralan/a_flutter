class KeychainKey {
  final String id;
  final String name;
  final String privateKey;
  final String publicKey;
  final DateTime createdAt;
  final bool isActive;

  KeychainKey({
    required this.id,
    required this.name,
    required this.privateKey,
    required this.publicKey,
    required this.createdAt,
    this.isActive = false,
  });

  KeychainKey copyWith({
    String? id,
    String? name,
    String? privateKey,
    String? publicKey,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return KeychainKey(
      id: id ?? this.id,
      name: name ?? this.name,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory KeychainKey.fromJson(Map<String, dynamic> json) {
    return KeychainKey(
      id: json['id'],
      name: json['name'],
      privateKey: json['privateKey'],
      publicKey: json['publicKey'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? false,
    );
  }
} 