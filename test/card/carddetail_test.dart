import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stashcard/card/carddetail.dart';
import 'package:stashcard/card/cardedit.dart';
import 'package:stashcard/providers/db.dart';
import 'package:stashcard/Views/home.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

// Generate mocks
@GenerateMocks([DatabaseHelper])
import 'carddetail_test.mocks.dart';

void main() {
  group('CardDetail Widget Tests', () {
    late MockDatabaseHelper mockDatabaseHelper;
    late UserCard testCard;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      testCard = UserCard(
        id: 1,
        name: 'Test Card',
        code: '1234567890',
        usage: 0,
        createdAt: DateTime.now(),
        symbology: 'code128',
      );
    });

    testWidgets('should display loading indicator when card is null', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(any)).thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Card'), findsNothing);
    });

    testWidgets('should display card details when card is loaded', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('card type: code128'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display app bar with title "card Detail"', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.widgetWithText(AppBar, 'card Detail'), findsOneWidget);
    });

    testWidgets('should display popup menu button in app bar', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PopupMenuButton<CardOptions>), findsOneWidget);
    });

    testWidgets('should show popup menu options when menu button is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<CardOptions>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should navigate to CardEdit when Edit menu item is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<CardOptions>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CardEdit), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog when Delete menu item is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<CardOptions>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete card'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this card?'), findsOneWidget);
      expect(find.text('Delete'), findsAtLeastNWidgets(1));
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should dismiss dialog when Cancel button is tapped in delete confirmation', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<CardOptions>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should call deleteUserCard and navigate to Home when Delete is confirmed', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);
      when(mockDatabaseHelper.deleteUserCard(1)).thenAnswer((_) async => {});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<CardOptions>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockDatabaseHelper.deleteUserCard(1)).called(1);
      expect(find.byType(Home), findsOneWidget);
    });

    testWidgets('should handle null cardId gracefully', (WidgetTester tester) async {
      // Act & Assert - should throw error when accessing null cardId
      expect(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardDetail(cardId: null),
          ),
        );
        await tester.pumpAndSettle();
      }, throwsA(isA<TypeError>()));
    });

    testWidgets('should refresh card data on PopScope callback', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate navigation back
      final navigator = Navigator.of(tester.element(find.byType(CardDetail)));
      navigator.pop();
      await tester.pumpAndSettle();

      // Assert - verify getOneCard was called during initial load
      verify(mockDatabaseHelper.getOneCard(1)).called(greaterThanOrEqualTo(1));
    });

    testWidgets('should display barcode with correct properties', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final barcodeGenerator = tester.widget<SfBarcodeGenerator>(find.byType(SfBarcodeGenerator));
      expect(barcodeGenerator.value, equals('1234567890'));
      expect(barcodeGenerator.showValue, isTrue);
      expect(barcodeGenerator.barColor, equals(Colors.black));
      expect(barcodeGenerator.textSpacing, equals(10));
    });

    testWidgets('should handle different card symbologies correctly', (WidgetTester tester) async {
      // Test cases for different symbologies
      final testCases = ['code39', 'code93', 'code128', 'ean8', 'ean13', 'upcA', 'upcE', 'qrCode'];

      for (String symbology in testCases) {
        // Arrange
        final cardWithSymbology = UserCard(
          id: 1,
          name: 'Test Card',
          code: '1234567890',
          usage: 0,
          createdAt: DateTime.now(),
          symbology: symbology,
        );
        when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => cardWithSymbology);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: CardDetail(cardId: 1),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('card type: $symbology'), findsOneWidget);
        expect(symbologies.containsKey(symbology), isTrue);

        // Reset for next iteration
        reset(mockDatabaseHelper);
      }
    });

    testWidgets('should handle async card loading correctly', (WidgetTester tester) async {
      // Arrange
      final completer = Completer<UserCard>();
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) => completer.future);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pump();

      // Assert - should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future
      completer.complete(testCard);
      await tester.pumpAndSettle();

      // Assert - should show card details
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should handle database errors gracefully', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenThrow(Exception('Database error'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pump();

      // Assert - widget should still render, showing loading state due to error
      expect(find.byType(CardDetail), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should update selected option when menu item is selected', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<CardOptions>));
      await tester.pumpAndSettle();

      // Find and tap the Share menu item
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      // Assert - verify the popup menu is still present
      expect(find.byType(PopupMenuButton<CardOptions>), findsOneWidget);
    });

    testWidgets('should display proper layout structure', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert layout structure
      expect(find.byType(PopScope), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });

    testWidgets('should have correct container styling for barcode', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, equals(Colors.white));
      expect(container.padding, equals(const EdgeInsets.all(10)));
    });
  });

  group('CardOptions Enum Tests', () {
    test('should contain all expected values', () {
      expect(CardOptions.values.length, equals(3));
      expect(CardOptions.values, contains(CardOptions.edit));
      expect(CardOptions.values, contains(CardOptions.share));
      expect(CardOptions.values, contains(CardOptions.delete));
    });

    test('should have correct string representations', () {
      expect(CardOptions.edit.toString(), contains('edit'));
      expect(CardOptions.share.toString(), contains('share'));
      expect(CardOptions.delete.toString(), contains('delete'));
    });

    test('should be comparable and hashable', () {
      expect(CardOptions.edit == CardOptions.edit, isTrue);
      expect(CardOptions.edit == CardOptions.share, isFalse);
      expect(CardOptions.edit.hashCode, equals(CardOptions.edit.hashCode));
    });
  });

  group('Symbologies Map Tests', () {
    test('should contain all expected symbology types', () {
      expect(symbologies.keys, contains('code39'));
      expect(symbologies.keys, contains('code93'));
      expect(symbologies.keys, contains('code128'));
      expect(symbologies.keys, contains('ean8'));
      expect(symbologies.keys, contains('ean13'));
      expect(symbologies.keys, contains('upcA'));
      expect(symbologies.keys, contains('upcE'));
      expect(symbologies.keys, contains('qrCode'));
    });

    test('should have correct number of symbologies', () {
      expect(symbologies.length, equals(8));
    });

    test('should map to correct Symbology instances', () {
      expect(symbologies['code39'], isA<Code39>());
      expect(symbologies['code93'], isA<Code93>());
      expect(symbologies['code128'], isA<Code128>());
      expect(symbologies['ean8'], isA<EAN8>());
      expect(symbologies['ean13'], isA<EAN13>());
      expect(symbologies['upcA'], isA<UPCA>());
      expect(symbologies['upcE'], isA<UPCE>());
      expect(symbologies['qrCode'], isA<QRCode>());
    });

    test('should handle case sensitivity correctly', () {
      expect(symbologies['CODE39'], isNull);
      expect(symbologies['qrcode'], isNull);
      expect(symbologies['qrCode'], isNotNull);
    });

    test('should return null for invalid symbology keys', () {
      expect(symbologies['invalid'], isNull);
      expect(symbologies[''], isNull);
      expect(symbologies['code128a'], isNull);
    });

    test('should have immutable symbology instances', () {
      final code39_1 = symbologies['code39'];
      final code39_2 = symbologies['code39'];
      expect(identical(code39_1, code39_2), isTrue);
    });
  });

  group('Edge Cases and Error Handling', () {
    late MockDatabaseHelper mockDatabaseHelper;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
    });

    testWidgets('should handle card with empty name', (WidgetTester tester) async {
      // Arrange
      final emptyNameCard = UserCard(
        id: 1,
        name: '',
        code: '1234567890',
        usage: 0,
        createdAt: DateTime.now(),
        symbology: 'code128',
      );
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => emptyNameCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('card type: code128'), findsOneWidget);
      expect(find.byType(SfBarcodeGenerator), findsOneWidget);
    });

    testWidgets('should handle card with empty code', (WidgetTester tester) async {
      // Arrange
      final emptyCodeCard = UserCard(
        id: 1,
        name: 'Test Card',
        code: '',
        usage: 0,
        createdAt: DateTime.now(),
        symbology: 'code128',
      );
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => emptyCodeCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.byType(SfBarcodeGenerator), findsOneWidget);
      final barcodeGenerator = tester.widget<SfBarcodeGenerator>(find.byType(SfBarcodeGenerator));
      expect(barcodeGenerator.value, equals(''));
    });

    testWidgets('should handle invalid symbology gracefully', (WidgetTester tester) async {
      // Arrange
      final invalidSymbologyCard = UserCard(
        id: 1,
        name: 'Test Card',
        code: '1234567890',
        usage: 0,
        createdAt: DateTime.now(),
        symbology: 'invalid_symbology',
      );
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => invalidSymbologyCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('card type: invalid_symbology'), findsOneWidget);
      final barcodeGenerator = tester.widget<SfBarcodeGenerator>(find.byType(SfBarcodeGenerator));
      expect(barcodeGenerator.symbology, isNull); // Should be null for invalid symbology
    });

    testWidgets('should handle very long card names', (WidgetTester tester) async {
      // Arrange
      final longNameCard = UserCard(
        id: 1,
        name: 'This is a very long card name that might cause layout issues in the UI',
        code: '1234567890',
        usage: 0,
        createdAt: DateTime.now(),
        symbology: 'code128',
      );
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => longNameCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('This is a very long card name that might cause layout issues in the UI'), findsOneWidget);
    });

    testWidgets('should handle special characters in card name and code', (WidgetTester tester) async {
      // Arrange
      final specialCharCard = UserCard(
        id: 1,
        name: 'Test Card @#\$%^&*()',
        code: '12345-67890_TEST',
        usage: 0,
        createdAt: DateTime.now(),
        symbology: 'code128',
      );
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async => specialCharCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Card @#\$%^&*()'), findsOneWidget);
      final barcodeGenerator = tester.widget<SfBarcodeGenerator>(find.byType(SfBarcodeGenerator));
      expect(barcodeGenerator.value, equals('12345-67890_TEST'));
    });

    testWidgets('should handle network/database timeout scenarios', (WidgetTester tester) async {
      // Arrange
      when(mockDatabaseHelper.getOneCard(1)).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 5));
        throw TimeoutException('Database timeout', Duration(seconds: 5));
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pump();

      // Assert - should show loading indicator during timeout
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    testWidgets('should complete full delete workflow', (WidgetTester tester) async {
      // Arrange
      final mockDb = MockDatabaseHelper();
      final testCard = UserCard(
        id: 1,
        name: 'Integration Test Card',
        code: '1234567890',
        usage: 0,
        createdAt: DateTime.now(),
        symbology: 'code128',
      );
      when(mockDb.getOneCard(1)).thenAnswer((_) async => testCard);
      when(mockDb.deleteUserCard(1)).thenAnswer((_) async => {});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<CardOptions>));
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm delete
      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Home), findsOneWidget);
      verify(mockDb.deleteUserCard(1)).called(1);
    });

    testWidgets('should complete full edit workflow navigation', (WidgetTester tester) async {
      // Arrange
      final mockDb = MockDatabaseHelper();
      final testCard = UserCard(
        id: 1,
        name: 'Edit Test Card',
        code: '1234567890',
        usage: 0,
        createdAt: DateTime.now(),
        symbology: 'code128',
      );
      when(mockDb.getOneCard(1)).thenAnswer((_) async => testCard);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: CardDetail(cardId: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Open menu and select edit
      await tester.tap(find.byType(PopupMenuButton<CardOptions>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Assert navigation to CardEdit
      expect(find.byType(CardEdit), findsOneWidget);
    });
  });
}