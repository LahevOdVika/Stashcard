class UserCard {
  final int? id;
  final String name;
  final String code;
  final int usage;
  final DateTime createdAt;
  final String symbology;

  const UserCard({
    this.id,
    required this.name,
    required this.code,
    required this.usage,
    required this.createdAt,
    required this.symbology,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'usage': usage,
      'created_at': createdAt.toIso8601String(),
      'symbology': symbology,
    };
  }

  @override
  String toString() {
    return 'UserCard{id: $id, name: $name, code: $code, usage $usage, created_at: $createdAt, symbology: $symbology}';
  }

  UserCard copyWith({int? id, String? name, String? code, int? usage, DateTime? createdAt, String? symbology}) {
    return UserCard(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      usage: usage ?? this.usage,
      createdAt: createdAt ?? this.createdAt,
      symbology: symbology ?? this.symbology,
    );
  }
}
