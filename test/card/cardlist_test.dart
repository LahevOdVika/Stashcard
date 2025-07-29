import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stashcard/card/cardlist.dart';
import 'package:stashcard/card/scanner.dart';

void main() {
  group('loadCards function tests', () {
    setUp(() {
      // Mock the asset bundle for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          return const StandardMessageCodec().encodeMessage(
            'Visa\nMasterCard\nAmerican Express\nDiscover\nJCB\nDiners Club\nUnionPay\n'
          );
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test('should load and filter cards correctly with empty filter', () async {
      final result = await loadCards('');
      expect(result, isA<List<String>>());
      expect(result.length, 7);
      expect(result, contains('Visa'));
      expect(result, contains('MasterCard'));
      expect(result, contains('American Express'));
    });

    test('should filter cards case-insensitively', () async {
      final result = await loadCards('visa');
      expect(result, hasLength(1));
      expect(result.first, 'Visa');
    });

    test('should filter cards with partial matches', () async {
      final result = await loadCards('card');
      expect(result, hasLength(1));
      expect(result.first, 'MasterCard');
    });

    test('should return empty list when no matches found', () async {
      final result = await loadCards('nonexistent');
      expect(result, isEmpty);
    });

    test('should handle uppercase filter correctly', () async {
      final result = await loadCards('AMERICAN');
      expect(result, hasLength(1));
      expect(result.first, 'American Express');
    });

    test('should handle mixed case filter correctly', () async {
      final result = await loadCards('DiNeRs');
      expect(result, hasLength(1));
      expect(result.first, 'Diners Club');
    });

    test('should filter multiple results', () async {
      final result = await loadCards('e');
      expect(result.length, greaterThan(1));
      expect(result, contains('American Express'));
      expect(result, contains('Discover'));
    });

    test('should handle empty lines and whitespace in asset file', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          return const StandardMessageCodec().encodeMessage(
            'Visa\n  \nMasterCard\n\n  American Express  \n'
          );
        }
        return null;
      });

      final result = await loadCards('');
      expect(result, hasLength(3));
      expect(result, contains('Visa'));
      expect(result, contains('MasterCard'));
      expect(result, contains('American Express'));
    });

    test('should handle asset file with only whitespace', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          return const StandardMessageCodec().encodeMessage('   \n  \n  ');
        }
        return null;
      });

      final result = await loadCards('');
      expect(result, isEmpty);
    });

    test('should handle special characters in filter', () async {
      final result = await loadCards('&');
      expect(result, isEmpty);
    });

    test('should handle numeric filter', () async {
      final result = await loadCards('123');
      expect(result, isEmpty);
    });

    test('should handle whitespace in filter', () async {
      final result = await loadCards(' visa ');
      expect(result, hasLength(1));
      expect(result.first, 'Visa');
    });
  });

  group('CardList widget tests', () {
    testWidgets('should display app bar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      expect(find.text('Add card'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should toggle search mode on search icon tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      // Initially should show search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byType(TextField), findsNothing);
      
      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      
      // Should now show close icon and text field
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should exit search mode and clear query on close tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      // Enter search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      
      // Enter some text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();
      
      // Exit search mode
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      // Should return to normal mode
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Add card'), findsOneWidget);
    });

    testWidgets('should update search query on text field change', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      // Enter search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      
      // Enter text in search field
      await tester.enterText(find.byType(TextField), 'visa');
      await tester.pump();
      
      // Verify the text field contains the entered text
      expect(find.text('visa'), findsOneWidget);
    });

    testWidgets('should display search hint text', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      // Enter search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      
      // Check for hint text
      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('should have correct text field properties', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      // Enter search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, true);
      expect(textField.decoration?.border, InputBorder.none);
      expect(textField.decoration?.hintStyle?.color, Colors.white);
    });

    testWidgets('should create CardListBody with empty search query initially', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      // Verify CardListBody is created with empty search query
      final cardListBody = tester.widget<CardListBody>(find.byType(CardListBody));
      expect(cardListBody.searchQuery, '');
    });

    testWidgets('should pass search query to CardListBody', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      // Enter search mode and add query
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      
      // Verify CardListBody receives the search query
      final cardListBody = tester.widget<CardListBody>(find.byType(CardListBody));
      expect(cardListBody.searchQuery, 'test');
    });

    testWidgets('should toggle search mode multiple times', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      // Toggle search on
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
      
      // Toggle search off
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.byType(TextField), findsNothing);
      
      // Toggle search on again
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should maintain widget key', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CardList()));
      
      final cardList = tester.widget<CardList>(find.byType(CardList));
      expect(cardList.key, isNotNull);
    });
  });

  group('CardListBody widget tests', () {
    setUp(() {
      // Mock the asset bundle
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          return const StandardMessageCodec().encodeMessage(
            'Visa\nMasterCard\nAmerican Express\nDiscover\n'
          );
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    testWidgets('should display list of cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      // Wait for async data to load
      await tester.pump();
      await tester.pump(); // Additional pump for FutureBuilder
      
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('should display filtered cards based on search query', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody(searchQuery: 'visa')),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('Visa'), findsOneWidget);
      expect(find.text('MasterCard'), findsNothing);
    });

    testWidgets('should display empty state when no cards match', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody(searchQuery: 'nonexistent')),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('Žádné karty'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('should handle asset loading error', (WidgetTester tester) async {
      // Mock asset loading failure
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        throw Exception('Asset not found');
      });

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.textContaining('Chyba:'), findsOneWidget);
    });

    testWidgets('should navigate to Scanner on card tap', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const Scaffold(body: CardListBody()),
        routes: {
          '/scanner': (context) => const Scanner(cardName: 'test'),
        },
      ));
      
      await tester.pump();
      await tester.pump();
      
      // Find and tap the first card
      final firstCard = find.byType(ListTile).first;
      expect(firstCard, findsOneWidget);
      
      await tester.tap(firstCard);
      await tester.pumpAndSettle();
      
      // Verify navigation occurred (Scanner widget should be present)
      expect(find.byType(Scanner), findsOneWidget);
    });

    testWidgets('should update cards when search query changes', (WidgetTester tester) async {
      // Create a stateful widget to test didUpdateWidget
      String searchQuery = '';
      late StateSetter setStateCallback;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              setStateCallback = setState;
              return CardListBody(searchQuery: searchQuery);
            },
          ),
        ),
      ));
      
      await tester.pump();
      await tester.pump();
      
      // Initially should show all cards
      expect(find.byType(ListTile), findsNWidgets(4));
      
      // Update search query
      setStateCallback(() {
        searchQuery = 'visa';
      });
      await tester.pump();
      await tester.pump();
      
      // Should now show only filtered results
      expect(find.text('Visa'), findsOneWidget);
      expect(find.text('MasterCard'), findsNothing);
    });

    testWidgets('should display dividers between list items', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('should handle empty asset file', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          return const StandardMessageCodec().encodeMessage('');
        }
        return null;
      });

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('Žádné karty'), findsOneWidget);
    });

    testWidgets('should maintain search query state correctly', (WidgetTester tester) async {
      const testQuery = 'american';
      
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody(searchQuery: testQuery)),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('American Express'), findsOneWidget);
      expect(find.text('Visa'), findsNothing);
      expect(find.text('MasterCard'), findsNothing);
    });

    testWidgets('should handle loading state', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      // Only first pump - should still be loading
      await tester.pump();
      
      // Should show CircularProgressIndicator or empty state while loading
      // Flutter's FutureBuilder shows nothing while loading by default
      expect(find.byType(ListView), findsNothing);
      expect(find.text('Žádné karty'), findsNothing);
    });

    testWidgets('should pass correct card name to Scanner', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const Scaffold(body: CardListBody()),
        onGenerateRoute: (settings) {
          if (settings.name == '/scanner') {
            final args = settings.arguments as Map<String, String>?;
            return MaterialPageRoute(
              builder: (context) => Scanner(cardName: args?['cardName'] ?? 'default'),
            );
          }
          return null;
        },
      ));
      
      await tester.pump();
      await tester.pump();
      
      // Tap on Visa card
      await tester.tap(find.text('Visa'));
      await tester.pumpAndSettle();
      
      // Verify Scanner received correct card name
      final scanner = tester.widget<Scanner>(find.byType(Scanner));
      expect(scanner.cardName, 'Visa');
    });

    testWidgets('should handle different search query types', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody(searchQuery: 'VISA')),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('Visa'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should maintain widget key', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      final cardListBody = tester.widget<CardListBody>(find.byType(CardListBody));
      expect(cardListBody.key, isNotNull);
    });

    testWidgets('should not reload data when search query remains same', (WidgetTester tester) async {
      const testQuery = 'visa';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => const CardListBody(searchQuery: testQuery),
          ),
        ),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('Visa'), findsOneWidget);
      
      // Rebuild with same search query
      await tester.pump();
      
      // Should still show same results without additional loading
      expect(find.text('Visa'), findsOneWidget);
    });
  });

  group('CardListBody lifecycle tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          return const StandardMessageCodec().encodeMessage('Visa\nMasterCard\n');
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    testWidgets('should initialize with correct search query', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody(searchQuery: 'visa')),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('Visa'), findsOneWidget);
      expect(find.text('MasterCard'), findsNothing);
    });

    testWidgets('should handle empty search query gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody(searchQuery: '')),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('should handle default constructor parameters', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      await tester.pump();
      await tester.pump();
      
      // Should work with default empty search query
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('should properly dispose resources', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      await tester.pump();
      await tester.pump();
      
      // Remove the widget
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Container()),
      ));
      
      // Should not throw any errors during disposal
      expect(tester.takeException(), isNull);
    });
  });

  group('Error handling and edge cases', () {
    testWidgets('should handle malformed asset data', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          // Return malformed data
          return const StandardMessageCodec().encodeMessage('\n\n\n');
        }
        return null;
      });

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('Žádné karty'), findsOneWidget);
    });

    testWidgets('should handle very long card names', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          return const StandardMessageCodec().encodeMessage(
            'Very Long Card Company Name That Might Cause Display Issues\n'
          );
        }
        return null;
      });

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.textContaining('Very Long Card Company Name'), findsOneWidget);
    });

    testWidgets('should handle unicode characters in card names', (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          return const StandardMessageCodec().encodeMessage('Visá\nMasterCård\n中国银联\n');
        }
        return null;
      });

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CardListBody()),
      ));
      
      await tester.pump();
      await tester.pump();
      
      expect(find.text('Visá'), findsOneWidget);
      expect(find.text('MasterCård'), findsOneWidget);
      expect(find.text('中国银联'), findsOneWidget);
    });

    test('should handle concurrent loadCards calls', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StandardMessageCodec().decodeMessage(message!) as String;
        if (key == 'assets/cardCompanies') {
          // Simulate slow loading
          await Future.delayed(const Duration(milliseconds: 100));
          return const StandardMessageCodec().encodeMessage('Visa\nMasterCard\n');
        }
        return null;
      });

      // Make concurrent calls
      final futures = [
        loadCards('visa'),
        loadCards('master'),
        loadCards(''),
      ];

      final results = await Future.wait(futures);
      
      expect(results[0], hasLength(1));
      expect(results[1], hasLength(1));
      expect(results[2], hasLength(2));
    });
  });
}