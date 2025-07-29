import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

import '../../lib/providers/db.dart';
import '../../lib/Views/home.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('UserCard Model Tests', () {
    late DateTime testDate;
    late UserCard testCard;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30, 0);
      testCard = UserCard(
        id: 1,
        name: 'Test Card',
        code: '123456789',
        usage: 5,
        createdAt: testDate,
        symbology: 'CODE128',
      );
    });

    test('should create UserCard with all required fields', () {
      expect(testCard.id, equals(1));
      expect(testCard.name, equals('Test Card'));
      expect(testCard.code, equals('123456789'));
      expect(testCard.usage, equals(5));
      expect(testCard.createdAt, equals(testDate));
      expect(testCard.symbology, equals('CODE128'));
    });

    test('should create UserCard without id (nullable)', () {
      final cardWithoutId = UserCard(
        name: 'Test Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      expect(cardWithoutId.id, isNull);
      expect(cardWithoutId.name, equals('Test Card'));
    });

    test('toMap() should convert UserCard to correct map format', () {
      final map = testCard.toMap();
      
      expect(map['id'], equals(1));
      expect(map['name'], equals('Test Card'));
      expect(map['code'], equals('123456789'));
      expect(map['usage'], equals(5));
      expect(map['created_at'], equals(testDate.toIso8601String()));
      expect(map['symbology'], equals('CODE128'));
    });

    test('toMap() should handle null id correctly', () {
      final cardWithoutId = UserCard(
        name: 'Test Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      final map = cardWithoutId.toMap();
      expect(map['id'], isNull);
    });

    test('toString() should return formatted string representation', () {
      final stringRep = testCard.toString();
      
      expect(stringRep, contains('UserCard{'));
      expect(stringRep, contains('id: 1'));
      expect(stringRep, contains('name: Test Card'));
      expect(stringRep, contains('code: 123456789'));
      expect(stringRep, contains('usage 5'));
      expect(stringRep, contains('created_at: $testDate'));
      expect(stringRep, contains('symbology: CODE128'));
    });

    test('copyWith() should create new instance with updated values', () {
      final updatedCard = testCard.copyWith(
        name: 'Updated Card',
        usage: 10,
      );
      
      expect(updatedCard.id, equals(1));
      expect(updatedCard.name, equals('Updated Card'));
      expect(updatedCard.code, equals('123456789'));
      expect(updatedCard.usage, equals(10));
      expect(updatedCard.createdAt, equals(testDate));
      expect(updatedCard.symbology, equals('CODE128'));
    });

    test('copyWith() should preserve original values when no parameters provided', () {
      final copiedCard = testCard.copyWith();
      
      expect(copiedCard.id, equals(testCard.id));
      expect(copiedCard.name, equals(testCard.name));
      expect(copiedCard.code, equals(testCard.code));
      expect(copiedCard.usage, equals(testCard.usage));
      expect(copiedCard.createdAt, equals(testCard.createdAt));
      expect(copiedCard.symbology, equals(testCard.symbology));
    });

    test('copyWith() should update all fields when all parameters provided', () {
      final newDate = DateTime(2024, 2, 20, 15, 45, 0);
      final newCard = testCard.copyWith(
        id: 99,
        name: 'Completely New Card',
        code: '987654321',
        usage: 25,
        createdAt: newDate,
        symbology: 'QR_CODE',
      );
      
      expect(newCard.id, equals(99));
      expect(newCard.name, equals('Completely New Card'));
      expect(newCard.code, equals('987654321'));
      expect(newCard.usage, equals(25));
      expect(newCard.createdAt, equals(newDate));
      expect(newCard.symbology, equals('QR_CODE'));
    });

    test('should handle edge cases for string fields', () {
      final edgeCaseCard = UserCard(
        name: '',
        code: '',
        usage: 0,
        createdAt: testDate,
        symbology: '',
      );
      
      expect(edgeCaseCard.name, equals(''));
      expect(edgeCaseCard.code, equals(''));
      expect(edgeCaseCard.symbology, equals(''));
    });

    test('should handle large usage numbers', () {
      final largeUsageCard = UserCard(
        name: 'High Usage Card',
        code: '123456789',
        usage: 999999,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      expect(largeUsageCard.usage, equals(999999));
    });

    test('should handle special characters in fields', () {
      final specialCard = UserCard(
        name: 'Special Card áéíóú ñ 中文',
        code: '!@#$%^&*()',
        usage: 0,
        createdAt: testDate,
        symbology: 'EAN-13',
      );
      
      expect(specialCard.name, equals('Special Card áéíóú ñ 中文'));
      expect(specialCard.code, equals('!@#$%^&*()'));
      expect(specialCard.symbology, equals('EAN-13'));
    });

    test('should handle negative usage numbers', () {
      final negativeUsageCard = UserCard(
        name: 'Negative Usage Card',
        code: '123456789',
        usage: -5,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      expect(negativeUsageCard.usage, equals(-5));
    });

    test('should handle zero usage', () {
      final zeroUsageCard = UserCard(
        name: 'Zero Usage Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      expect(zeroUsageCard.usage, equals(0));
    });

    test('should handle DateTime edge cases', () {
      final futureDate = DateTime(2099, 12, 31, 23, 59, 59);
      final pastDate = DateTime(1900, 1, 1, 0, 0, 0);
      
      final futureCard = testCard.copyWith(createdAt: futureDate);
      final pastCard = testCard.copyWith(createdAt: pastDate);
      
      expect(futureCard.createdAt, equals(futureDate));
      expect(pastCard.createdAt, equals(pastDate));
    });
  });

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;
    late DateTime testDate;
    
    setUp(() async {
      dbHelper = DatabaseHelper();
      testDate = DateTime(2024, 1, 15, 10, 30, 0);
      
      // Clean up any existing data
      try {
        await dbHelper.deleteAllCards();
      } catch (e) {
        // Database might not exist yet, ignore error
      }
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await dbHelper.deleteAllCards();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    test('should get database instance', () async {
      final db = await dbHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should return same database instance on subsequent calls', () async {
      final db1 = await dbHelper.database;
      final db2 = await dbHelper.database;
      expect(identical(db1, db2), isTrue);
    });

    test('should insert card successfully', () async {
      final card = UserCard(
        name: 'Test Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(card);
      final cards = await dbHelper.getUserCards();
      
      expect(cards.length, equals(1));
      expect(cards[0].name, equals('Test Card'));
      expect(cards[0].code, equals('123456789'));
    });

    test('should replace card on conflict', () async {
      final card1 = UserCard(
        id: 1,
        name: 'Original Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      final card2 = UserCard(
        id: 1,
        name: 'Updated Card',
        code: '987654321',
        usage: 5,
        createdAt: testDate,
        symbology: 'QR_CODE',
      );
      
      await dbHelper.insertCard(card1);
      await dbHelper.insertCard(card2);
      
      final cards = await dbHelper.getUserCards();
      expect(cards.length, equals(1));
      expect(cards[0].name, equals('Updated Card'));
      expect(cards[0].code, equals('987654321'));
    });

    test('should retrieve all user cards', () async {
      final cards = [
        UserCard(name: 'Card 1', code: '111', usage: 1, createdAt: testDate, symbology: 'CODE128'),
        UserCard(name: 'Card 2', code: '222', usage: 2, createdAt: testDate, symbology: 'QR_CODE'),
        UserCard(name: 'Card 3', code: '333', usage: 3, createdAt: testDate, symbology: 'EAN13'),
      ];
      
      for (final card in cards) {
        await dbHelper.insertCard(card);
      }
      
      final retrievedCards = await dbHelper.getUserCards();
      expect(retrievedCards.length, equals(3));
    });

    test('should return empty list when no cards exist', () async {
      final cards = await dbHelper.getUserCards();
      expect(cards, isEmpty);
    });

    test('should get cards sorted by name ascending', () async {
      final cards = [
        UserCard(name: 'Zebra Card', code: '111', usage: 1, createdAt: testDate, symbology: 'CODE128'),
        UserCard(name: 'Alpha Card', code: '222', usage: 2, createdAt: testDate, symbology: 'QR_CODE'),
        UserCard(name: 'Beta Card', code: '333', usage: 3, createdAt: testDate, symbology: 'EAN13'),
      ];
      
      for (final card in cards) {
        await dbHelper.insertCard(card);
      }
      
      final sortedCards = await dbHelper.getUserCardsSorted(SortOptions.byName);
      expect(sortedCards[0].name, equals('Alpha Card'));
      expect(sortedCards[1].name, equals('Beta Card'));
      expect(sortedCards[2].name, equals('Zebra Card'));
    });

    test('should get cards sorted by usage descending', () async {
      final cards = [
        UserCard(name: 'Low Usage', code: '111', usage: 1, createdAt: testDate, symbology: 'CODE128'),
        UserCard(name: 'High Usage', code: '222', usage: 10, createdAt: testDate, symbology: 'QR_CODE'),
        UserCard(name: 'Medium Usage', code: '333', usage: 5, createdAt: testDate, symbology: 'EAN13'),
      ];
      
      for (final card in cards) {
        await dbHelper.insertCard(card);
      }
      
      final sortedCards = await dbHelper.getUserCardsSorted(SortOptions.byUsage);
      expect(sortedCards[0].name, equals('High Usage'));
      expect(sortedCards[1].name, equals('Medium Usage'));
      expect(sortedCards[2].name, equals('Low Usage'));
    });

    test('should get cards sorted by date created descending', () async {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 2);
      final date3 = DateTime(2024, 1, 3);
      
      final cards = [
        UserCard(name: 'Oldest', code: '111', usage: 1, createdAt: date1, symbology: 'CODE128'),
        UserCard(name: 'Newest', code: '222', usage: 2, createdAt: date3, symbology: 'QR_CODE'),
        UserCard(name: 'Middle', code: '333', usage: 3, createdAt: date2, symbology: 'EAN13'),
      ];
      
      for (final card in cards) {
        await dbHelper.insertCard(card);
      }
      
      final sortedCards = await dbHelper.getUserCardsSorted(SortOptions.byDateCreated);
      expect(sortedCards[0].name, equals('Newest'));
      expect(sortedCards[1].name, equals('Middle'));
      expect(sortedCards[2].name, equals('Oldest'));
    });

    test('should retrieve one card by id', () async {
      final card = UserCard(
        name: 'Specific Card',
        code: '123456789',
        usage: 5,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(card);
      final cards = await dbHelper.getUserCards();
      final cardId = cards[0].id!;
      
      final retrievedCard = await dbHelper.getOneCard(cardId);
      expect(retrievedCard.name, equals('Specific Card'));
      expect(retrievedCard.id, equals(cardId));
    });

    test('getOneCard should throw when card does not exist', () async {
      expect(() => dbHelper.getOneCard(999), throwsA(isA<RangeError>()));
    });

    test('should get last added card', () async {
      final cards = [
        UserCard(name: 'First Card', code: '111', usage: 1, createdAt: testDate, symbology: 'CODE128'),
        UserCard(name: 'Second Card', code: '222', usage: 2, createdAt: testDate, symbology: 'QR_CODE'),
        UserCard(name: 'Last Card', code: '333', usage: 3, createdAt: testDate, symbology: 'EAN13'),
      ];
      
      for (final card in cards) {
        await dbHelper.insertCard(card);
      }
      
      final lastCard = await dbHelper.getLastAddedCard();
      expect(lastCard.name, equals('Last Card'));
    });

    test('getLastAddedCard should throw when no cards exist', () async {
      expect(() => dbHelper.getLastAddedCard(), throwsA(isA<RangeError>()));
    });

    test('should increment usage count', () async {
      final card = UserCard(
        name: 'Usage Card',
        code: '123456789',
        usage: 5,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(card);
      final cards = await dbHelper.getUserCards();
      final cardId = cards[0].id!;
      
      await dbHelper.incrementUsage(cardId);
      
      final updatedCard = await dbHelper.getOneCard(cardId);
      expect(updatedCard.usage, equals(6));
    });

    test('should increment usage from zero', () async {
      final card = UserCard(
        name: 'Zero Usage Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(card);
      final cards = await dbHelper.getUserCards();
      final cardId = cards[0].id!;
      
      await dbHelper.incrementUsage(cardId);
      
      final updatedCard = await dbHelper.getOneCard(cardId);
      expect(updatedCard.usage, equals(1));
    });

    test('should handle incrementing usage for non-existent card', () async {
      expect(() => dbHelper.incrementUsage(999), throwsA(isA<RangeError>()));
    });

    test('should update user card', () async {
      final originalCard = UserCard(
        name: 'Original Name',
        code: '123456789',
        usage: 5,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(originalCard);
      final cards = await dbHelper.getUserCards();
      final cardId = cards[0].id!;
      
      final updatedCard = UserCard(
        id: cardId,
        name: 'Updated Name',
        code: '987654321',
        usage: 10,
        createdAt: testDate,
        symbology: 'QR_CODE',
      );
      
      await dbHelper.updateUserCard(updatedCard);
      
      final retrievedCard = await dbHelper.getOneCard(cardId);
      expect(retrievedCard.name, equals('Updated Name'));
      expect(retrievedCard.code, equals('987654321'));
      expect(retrievedCard.usage, equals(10));
      expect(retrievedCard.symbology, equals('QR_CODE'));
    });

    test('should delete all cards', () async {
      final cards = [
        UserCard(name: 'Card 1', code: '111', usage: 1, createdAt: testDate, symbology: 'CODE128'),
        UserCard(name: 'Card 2', code: '222', usage: 2, createdAt: testDate, symbology: 'QR_CODE'),
      ];
      
      for (final card in cards) {
        await dbHelper.insertCard(card);
      }
      
      expect((await dbHelper.getUserCards()).length, equals(2));
      
      await dbHelper.deleteAllCards();
      
      final remainingCards = await dbHelper.getUserCards();
      expect(remainingCards, isEmpty);
    });

    test('should delete specific user card', () async {
      final cards = [
        UserCard(name: 'Keep Card', code: '111', usage: 1, createdAt: testDate, symbology: 'CODE128'),
        UserCard(name: 'Delete Card', code: '222', usage: 2, createdAt: testDate, symbology: 'QR_CODE'),
      ];
      
      for (final card in cards) {
        await dbHelper.insertCard(card);
      }
      
      final allCards = await dbHelper.getUserCards();
      final cardToDelete = allCards.firstWhere((card) => card.name == 'Delete Card');
      
      await dbHelper.deleteUserCard(cardToDelete.id!);
      
      final remainingCards = await dbHelper.getUserCards();
      expect(remainingCards.length, equals(1));
      expect(remainingCards[0].name, equals('Keep Card'));
    });

    test('should handle deleting non-existent card gracefully', () async {
      // This should not throw an exception
      await dbHelper.deleteUserCard(999);
      
      final cards = await dbHelper.getUserCards();
      expect(cards, isEmpty);
    });

    test('should handle special characters in card data', () async {
      final specialCard = UserCard(
        name: 'Special Card áéíóú ñ 中文',
        code: '!@#$%^&*()',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(specialCard);
      final cards = await dbHelper.getUserCards();
      
      expect(cards[0].name, equals('Special Card áéíóú ñ 中文'));
      expect(cards[0].code, equals('!@#$%^&*()'));
    });

    test('should handle very long strings', () async {
      final longString = 'A' * 1000;
      final longCard = UserCard(
        name: longString,
        code: longString,
        usage: 0,
        createdAt: testDate,
        symbology: longString,
      );
      
      await dbHelper.insertCard(longCard);
      final cards = await dbHelper.getUserCards();
      
      expect(cards[0].name, equals(longString));
      expect(cards[0].code, equals(longString));
      expect(cards[0].symbology, equals(longString));
    });

    test('should preserve DateTime precision when storing and retrieving', () async {
      final preciseDate = DateTime(2024, 1, 15, 10, 30, 45, 123, 456);
      final card = UserCard(
        name: 'Precise Date Card',
        code: '123456789',
        usage: 0,
        createdAt: preciseDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(card);
      final cards = await dbHelper.getUserCards();
      
      // Note: Database storage may lose some precision, but should preserve at least milliseconds
      expect(cards[0].createdAt.year, equals(preciseDate.year));
      expect(cards[0].createdAt.month, equals(preciseDate.month));
      expect(cards[0].createdAt.day, equals(preciseDate.day));
      expect(cards[0].createdAt.hour, equals(preciseDate.hour));
      expect(cards[0].createdAt.minute, equals(preciseDate.minute));
      expect(cards[0].createdAt.second, equals(preciseDate.second));
    });

    test('should handle maximum integer values for usage', () async {
      const maxUsage = 9223372036854775807; // Max int64 value
      final maxUsageCard = UserCard(
        name: 'Max Usage Card',
        code: '123456789',
        usage: maxUsage,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(maxUsageCard);
      final cards = await dbHelper.getUserCards();
      
      expect(cards[0].usage, equals(maxUsage));
    });

    test('should handle concurrent database operations', () async {
      final futures = <Future>[];
      
      // Create multiple concurrent insert operations
      for (int i = 0; i < 10; i++) {
        final card = UserCard(
          name: 'Concurrent Card $i',
          code: 'CODE$i',
          usage: i,
          createdAt: testDate,
          symbology: 'CODE128',
        );
        futures.add(dbHelper.insertCard(card));
      }
      
      await Future.wait(futures);
      
      final cards = await dbHelper.getUserCards();
      expect(cards.length, equals(10));
    });

    test('should handle empty sort results', () async {
      final sortedCards = await dbHelper.getUserCardsSorted(SortOptions.byName);
      expect(sortedCards, isEmpty);
    });

    test('should maintain data integrity with multiple updates', () async {
      final card = UserCard(
        name: 'Test Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(card);
      final cards = await dbHelper.getUserCards();
      final cardId = cards[0].id!;
      
      // Multiple increments
      for (int i = 0; i < 5; i++) {
        await dbHelper.incrementUsage(cardId);
      }
      
      final finalCard = await dbHelper.getOneCard(cardId);
      expect(finalCard.usage, equals(5));
    });

    test('should handle null values in database properly', () async {
      final cardWithoutId = UserCard(
        name: 'No ID Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      await dbHelper.insertCard(cardWithoutId);
      final cards = await dbHelper.getUserCards();
      
      expect(cards.length, equals(1));
      expect(cards[0].id, isNotNull); // Should be auto-generated
      expect(cards[0].name, equals('No ID Card'));
    });

    test('should handle cards with identical names but different codes', () async {
      final card1 = UserCard(
        name: 'Duplicate Name',
        code: '111111111',
        usage: 1,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      final card2 = UserCard(
        name: 'Duplicate Name',
        code: '222222222',
        usage: 2,
        createdAt: testDate,
        symbology: 'QR_CODE',
      );
      
      await dbHelper.insertCard(card1);
      await dbHelper.insertCard(card2);
      
      final cards = await dbHelper.getUserCards();
      expect(cards.length, equals(2));
      expect(cards.where((card) => card.name == 'Duplicate Name').length, equals(2));
    });

    test('should handle sorting with equal values', () async {
      final sameDateCards = [
        UserCard(name: 'Card A', code: '111', usage: 5, createdAt: testDate, symbology: 'CODE128'),
        UserCard(name: 'Card B', code: '222', usage: 5, createdAt: testDate, symbology: 'QR_CODE'),
        UserCard(name: 'Card C', code: '333', usage: 5, createdAt: testDate, symbology: 'EAN13'),
      ];
      
      for (final card in sameDateCards) {
        await dbHelper.insertCard(card);
      }
      
      final sortedByUsage = await dbHelper.getUserCardsSorted(SortOptions.byUsage);
      expect(sortedByUsage.length, equals(3));
      // All have same usage, so order might vary but all should be present
      expect(sortedByUsage.map((card) => card.usage).toSet(), equals({5}));
    });

    test('should handle database with mixed symbology types', () async {
      final mixedCards = [
        UserCard(name: 'Barcode', code: '111', usage: 1, createdAt: testDate, symbology: 'CODE128'),
        UserCard(name: 'QR Code', code: '222', usage: 2, createdAt: testDate, symbology: 'QR_CODE'),
        UserCard(name: 'EAN Code', code: '333', usage: 3, createdAt: testDate, symbology: 'EAN13'),
        UserCard(name: 'PDF417', code: '444', usage: 4, createdAt: testDate, symbology: 'PDF417'),
        UserCard(name: 'Data Matrix', code: '555', usage: 5, createdAt: testDate, symbology: 'DATA_MATRIX'),
      ];
      
      for (final card in mixedCards) {
        await dbHelper.insertCard(card);
      }
      
      final allCards = await dbHelper.getUserCards();
      expect(allCards.length, equals(5));
      
      final symbologies = allCards.map((card) => card.symbology).toSet();
      expect(symbologies.length, equals(5)); // All different symbologies
    });

    test('should handle rapid successive database operations', () async {
      final card = UserCard(
        name: 'Rapid Test Card',
        code: '123456789',
        usage: 0,
        createdAt: testDate,
        symbology: 'CODE128',
      );
      
      // Insert, update, increment, retrieve in rapid succession
      await dbHelper.insertCard(card);
      final cards = await dbHelper.getUserCards();
      final cardId = cards[0].id!;
      
      final updatedCard = card.copyWith(id: cardId, name: 'Updated Rapid Card');
      await dbHelper.updateUserCard(updatedCard);
      await dbHelper.incrementUsage(cardId);
      
      final finalCard = await dbHelper.getOneCard(cardId);
      expect(finalCard.name, equals('Updated Rapid Card'));
      expect(finalCard.usage, equals(1));
    });
  });
}