import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stashcard/main.dart';

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

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
        join(await getDatabasesPath(), 'user_cards.db'),
        onCreate: (db, version) {
          return db.execute(
              'CREATE TABLE user_cards(id INTEGER PRIMARY KEY, name TEXT, code TEXT, usage INTEGER, created_at DATETIME DEFAULT CURRENT_TIMESTAMP, symbology TEXT)'
          );
        },
        version: 1
    );
    return _database!;
  }

  Future<void> insertCard(UserCard card) async {
    final db = await database;
    await db.insert(
        'user_cards',
        card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<UserCard>> getUserCards() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query('user_cards');
    return maps.map((map) => UserCard(
      id: map['id'] as int,
      name: map['name'] as String,
      code: map['code'] as String,
      usage: map['usage'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      symbology: map['symbology'] as String,
    )).toList();
  }

  Future<List<UserCard>> getUserCardsSorted(SortOptions selectedSort) async {
    final db = await database;

    String sort = switch (selectedSort) {
      SortOptions.byName => 'name ASC',
      SortOptions.byUsage => 'usage DESC',
      SortOptions.byDateCreated => 'created_at DESC',
    };

    final List<Map<String, Object?>> maps = await db.query(
        'user_cards',
        orderBy: sort
    );
    return maps.map((map) => UserCard(
      id: map['id'] as int,
      name: map['name'] as String,
      code: map['code'] as String,
      usage: map['usage'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      symbology: map['symbology'] as String,
    )).toList();
  }

  Future<UserCard> getOneCard(int id) async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
        'user_cards',
        where: 'id = ?',
        whereArgs: [id]
    );
    return UserCard(
      id: maps[0]['id'] as int,
      name: maps[0]['name'] as String,
      code: maps[0]['code'] as String,
      usage: maps[0]['usage'] as int,
      createdAt: DateTime.parse(maps[0]['created_at'] as String),
      symbology: maps[0]['symbology'] as String,
    );
  }

  Future<UserCard> getLastAddedCard() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
        'user_cards',
        orderBy: 'id DESC',
        limit: 1
    );
    return UserCard(
      id: maps[0]['id'] as int,
      name: maps[0]['name'] as String,
      code: maps[0]['code'] as String,
      usage: maps[0]['usage'] as int,
      createdAt: DateTime.parse(maps[0]['created_at'] as String),
      symbology: maps[0]['symbology'] as String,
    );
  }

  Future<void> incrementUsage(int cardId) async {
    final db = await database;

    UserCard? card = await getOneCard(cardId);

    int newUsage = card.usage + 1;

    await db.update(
      'user_cards',
      {'usage': newUsage},
      where: 'id = ?',
      whereArgs: [cardId],
    );
    }

  Future<void> updateUserCard(UserCard updatedCard) async {
    final db = await database;
    await db.update(
      'user_cards',
      updatedCard.toMap(),
      where: 'id = ?',
      whereArgs: [updatedCard.id],
    );
  }

  Future<void> deleteAllCards() async {
    final db = await database;
    await db.delete('user_cards');
  }

  Future<void> deleteUserCard(int id) async {
    final db = await database;
    await db.delete(
        'user_cards',
        where: 'id = ?',
        whereArgs: [id]
    );
  }
}