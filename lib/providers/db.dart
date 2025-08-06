import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stashcard/models/enums.dart';
import 'package:stashcard/models/card.dart';

/// Database helper to provide db functionality throughout the app
///
/// This helper provides basic CRUD functions, plus some more specific.
class DatabaseHelper {
  static Database? _database;

  /// Returns the database instance.
  ///
  /// If the database does not exist, it will be created.
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

  /// Inserts a new card into the database.
  ///
  /// If a card with the same [id] already exists, it will be replaced.
  ///
  /// Parameters:
  ///   [card]: The [UserCard] object to be inserted.
  Future<void> insertCard(UserCard card) async {
    final db = await database;
    await db.insert(
        'user_cards',
        card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  /// Retrieves all user cards from the database.
  ///
  /// Returns a list of [UserCard] objects.
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

  /// Retrieves all user cards from the database, sorted according to [selectedSort].
  ///
  /// Parameters:
  ///   [selectedSort]: The [SortOptions] to sort the cards by.
  ///
  /// Returns a list of [UserCard] objects.
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

  /// Retrieves a single card from the database by its [id].
  ///
  /// Parameters:
  ///  [id]: The id of the card to retrieve.
  ///
  /// Returns the [UserCard] object with the given [id].
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

  /// Retrieves the last added card from the database.
  ///
  /// Returns the last added [UserCard] object.
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

  /// Increments the usage count of a card by one.
  ///
  /// Parameters:
  ///  [cardId]: The id of the card to increment the usage count for.
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

  /// Updates an existing card in the database.
  ///
  /// Parameters:
  /// [updatedCard]: The [UserCard] object with updated information.
  Future<void> updateUserCard(UserCard updatedCard) async {
    final db = await database;
    await db.update(
      'user_cards',
      updatedCard.toMap(),
      where: 'id = ?',
      whereArgs: [updatedCard.id],
    );
  }

  /// Deletes all cards from the database.
  Future<void> deleteAllCards() async {
    final db = await database;
    await db.delete('user_cards');
  }

  /// Deletes a card from the database by its [id].
  ///
  /// Parameters:
  /// [id]: The id of the card to delete.
  Future<void> deleteUserCard(int id) async {
    final db = await database;
    await db.delete(
        'user_cards',
        where: 'id = ?',
        whereArgs: [id]
    );
  }
}
