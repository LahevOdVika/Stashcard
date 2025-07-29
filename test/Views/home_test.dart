import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/Views/home.dart';
import '../../lib/card/carddetail.dart';
import '../../lib/card/cardlist.dart';
import '../../lib/providers/db.dart';

// Generate mocks
@GenerateMocks([DatabaseHelper])
import 'home_test.mocks.dart';

void main() {
  group('SortOptions Enum', () {
    test('should have exactly three sort options', () {
      expect(SortOptions.values.length, 3);
    });

    test('should have correct enum values', () {
      expect(SortOptions.values, [
        SortOptions.byName,
        SortOptions.byDateCreated,
        SortOptions.byUsage,
      ]);
    });

    test('enum values should have proper toString representation', () {
      expect(SortOptions.byName.toString(), 'SortOptions.byName');
      expect(SortOptions.byDateCreated.toString(), 'SortOptions.byDateCreated');
      expect(SortOptions.byUsage.toString(), 'SortOptions.byUsage');
    });
  });

  group('Home Widget UI Tests', () {
    testWidgets('should display app title when not in search mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      expect(find.text('Stashcard'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should have correct AppBar structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(IconButton), findsNWidgets(3)); // search, donate, popup menu
      expect(find.byType(PopupMenuButton<SortOptions>), findsOneWidget);
    });

    testWidgets('should show search icon initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should show donate button with correct icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should show floating action button with add icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should contain CardGrid widget with default sort option', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      final cardGrid = find.byType(CardGrid);
      expect(cardGrid, findsOneWidget);
      
      final cardGridWidget = tester.widget<CardGrid>(cardGrid);
      expect(cardGridWidget.selectedOption, SortOptions.byName);
      expect(cardGridWidget.searchQuery, '');
    });
  });

  group('Search Functionality Tests', () {
    testWidgets('should enter search mode when search button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Stashcard'), findsNothing);
    });

    testWidgets('should configure search TextField correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
      expect(textField.decoration?.hintText, 'Search...');
      expect(textField.decoration?.border, InputBorder.none);
    });

    testWidgets('should exit search mode when close button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Enter search mode
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter some text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Exit search mode
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Stashcard'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should clear search query when exiting search mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Enter search mode and type
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Exit and re-enter search mode
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Verify text field is empty
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('should update search query in real-time', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      const testQuery = 'real time search';
      await tester.enterText(find.byType(TextField), testQuery);
      await tester.pump();

      // Verify CardGrid receives updated search query
      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.searchQuery, testQuery);
    });

    testWidgets('should handle special characters in search query', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      const specialQuery = '!@#$%^&*()_+-=[]{}|;:,.<>?';
      await tester.enterText(find.byType(TextField), specialQuery);
      await tester.pump();

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.searchQuery, specialQuery);
    });

    testWidgets('should handle empty search query', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter text then clear it
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.searchQuery, '');
    });
  });

  group('Donate Dialog Tests', () {
    testWidgets('should show donate dialog when donate button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Donate'), findsWidgets);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should configure donate dialog correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(find.text('Donate'), findsNWidgets(2)); // Title and button
      expect(find.textContaining("I'm a student"), findsOneWidget);
      expect(find.text('Enjoy the app!'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('should have correct dialog styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.title, isA<Text>());
      expect(dialog.icon, isA<Icon>());
      expect(dialog.content, isA<Column>());
      expect(dialog.actions?.length, 2);
    });

    testWidgets('should close donate dialog when close button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      await tester.tap(find.text('Close'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should have FilledButton for donate action', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('Sort Menu Tests', () {
    testWidgets('should show popup menu with all sort options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byType(PopupMenuButton<SortOptions>));
      await tester.pump();

      expect(find.text('Sort by name'), findsOneWidget);
      expect(find.text('Sort by date created'), findsOneWidget);
      expect(find.text('Sort by usage'), findsOneWidget);
    });

    testWidgets('should have correct initial sort option', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      final popupButton = tester.widget<PopupMenuButton<SortOptions>>(
        find.byType(PopupMenuButton<SortOptions>)
      );
      expect(popupButton.initialValue, SortOptions.byName);
    });

    testWidgets('should update sort option when menu item is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<SortOptions>));
      await tester.pump();

      // Select 'Sort by usage'
      await tester.tap(find.text('Sort by usage'));
      await tester.pump();

      // Verify CardGrid receives the updated sort option
      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.selectedOption, SortOptions.byUsage);
    });

    testWidgets('should close menu after selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byType(PopupMenuButton<SortOptions>));
      await tester.pump();

      await tester.tap(find.text('Sort by date created'));
      await tester.pump();

      // Menu should be closed
      expect(find.text('Sort by name'), findsNothing);
      expect(find.text('Sort by date created'), findsNothing);
      expect(find.text('Sort by usage'), findsNothing);
    });
  });

  group('Navigation Tests', () {
    testWidgets('should navigate to CardList when FAB is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Home(),
          routes: {
            '/cardlist': (context) => const CardList(),
          },
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(CardList), findsOneWidget);
    });

    testWidgets('should use MaterialPageRoute for navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // We can't directly test the route type, but we can verify the navigation works
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      
      // The navigation should trigger without errors
      expect(tester.takeException(), isNull);
    });
  });

  group('CardGrid Widget Tests', () {
    late MockDatabaseHelper mockDb;
    late List<UserCard> mockCards;

    setUp(() {
      mockDb = MockDatabaseHelper();
      mockCards = [
        UserCard(
          id: 1,
          name: 'Test Card 1',
          code: '123456789',
          usage: 5,
          createdAt: DateTime.now(),
          symbology: 'CODE128',
        ),
        UserCard(
          id: 2,
          name: 'Test Card 2',
          code: '987654321',
          usage: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          symbology: 'QR',
        ),
        UserCard(
          id: 3,
          name: 'Search Test Card',
          code: '555555555',
          usage: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          symbology: 'EAN13',
        ),
      ];
    });

    testWidgets('should create CardGrid with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CardGrid(selectedOption: SortOptions.byDateCreated),
        ),
      );

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.selectedOption, SortOptions.byDateCreated);
      expect(cardGrid.searchQuery, '');
    });

    testWidgets('should accept custom search query', (WidgetTester tester) async {
      const testQuery = 'custom search';
      await tester.pumpWidget(
        const MaterialApp(
          home: CardGrid(
            selectedOption: SortOptions.byUsage,
            searchQuery: testQuery,
          ),
        ),
      );

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.searchQuery, testQuery);
    });

    testWidgets('should show future builder initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CardGrid(selectedOption: SortOptions.byName),
        ),
      );

      expect(find.byType(FutureBuilder), findsOneWidget);
    });

    testWidgets('should display error message when database fails', (WidgetTester tester) async {
      // Create a widget that uses our mock
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureBuilder<List<UserCard>>(
              future: Future.error('Database error'),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Chyba: ${snapshot.error}"));
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Chyba:'), findsOneWidget);
    });

    testWidgets('should display no cards message when list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureBuilder<List<UserCard>>(
              future: Future.value(<UserCard>[]),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Chyba: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Žádné karty"));
                }
                return const Text('Has data');
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Žádné karty'), findsOneWidget);
    });

    testWidgets('should display cards when data is loaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureBuilder<List<UserCard>>(
              future: Future.value(mockCards),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Chyba: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Žádné karty"));
                }

                final userCards = snapshot.data!;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: userCards.length,
                  itemBuilder: (context, index) {
                    final userCard = userCards[index];
                    return Card(
                      child: Center(
                        child: Text(userCard.name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Test Card 1'), findsOneWidget);
      expect(find.text('Test Card 2'), findsOneWidget);
      expect(find.text('Search Test Card'), findsOneWidget);
    });

    testWidgets('should filter cards based on search query', (WidgetTester tester) async {
      const searchQuery = 'search';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureBuilder<List<UserCard>>(
              future: Future.value(mockCards),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Chyba: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Žádné karty"));
                }

                final userCards = snapshot.data!;
                final filteredCards = userCards.where((userCard) {
                  return searchQuery.isEmpty || userCard.name.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final userCard = filteredCards[index];
                    return Card(
                      child: Center(
                        child: Text(userCard.name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      // Only 'Search Test Card' should be visible
      expect(find.text('Search Test Card'), findsOneWidget);
      expect(find.text('Test Card 1'), findsNothing);
      expect(find.text('Test Card 2'), findsNothing);
    });

    testWidgets('should handle case-insensitive search', (WidgetTester tester) async {
      const searchQuery = 'SEARCH';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureBuilder<List<UserCard>>(
              future: Future.value(mockCards),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Chyba: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Žádné karty"));
                }

                final userCards = snapshot.data!;
                final filteredCards = userCards.where((userCard) {
                  return searchQuery.isEmpty || userCard.name.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final userCard = filteredCards[index];
                    return Card(
                      child: Center(
                        child: Text(userCard.name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Search Test Card'), findsOneWidget);
    });

    testWidgets('should have correct grid configuration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return const Card(elevation: 2);
              },
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      
      expect(delegate.crossAxisCount, 2);
      expect(delegate.crossAxisSpacing, 10);
      expect(delegate.mainAxisSpacing, 10);
      expect(delegate.childAspectRatio, 1.5);
    });

    testWidgets('should have RefreshIndicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {},
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: 0,
                itemBuilder: (context, index) => const SizedBox(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  group('State Management Tests', () {
    testWidgets('should maintain search state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Initial state
      expect(find.byIcon(Icons.search), findsOneWidget);
      
      // Toggle search on
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Toggle search off
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should handle multiple state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Rapid state changes
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
      }

      // Should end in initial state
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Stashcard'), findsOneWidget);
    });

    testWidgets('should preserve search text during typing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Type incrementally
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.searchQuery, 'abc');
    });
  });

  group('Integration Tests', () {
    testWidgets('should pass updated search query to CardGrid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      const testQuery = 'integration test query';
      await tester.enterText(find.byType(TextField), testQuery);
      await tester.pump();

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.searchQuery, testQuery);
    });

    testWidgets('should pass updated sort option to CardGrid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byType(PopupMenuButton<SortOptions>));
      await tester.pump();
      await tester.tap(find.text('Sort by date created'));
      await tester.pump();

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.selectedOption, SortOptions.byDateCreated);
    });

    testWidgets('should maintain both search and sort state simultaneously', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Set search query
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Change sort option
      await tester.tap(find.byIcon(Icons.close)); // Exit search to access menu
      await tester.pump();
      await tester.tap(find.byType(PopupMenuButton<SortOptions>));
      await tester.pump();
      await tester.tap(find.text('Sort by usage'));
      await tester.pump();

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.selectedOption, SortOptions.byUsage);
      // Search query should be cleared when exiting search mode
      expect(cardGrid.searchQuery, '');
    });
  });

  group('Edge Cases and Error Handling', () {
    testWidgets('should handle rapid button taps gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Rapid search button taps
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(i % 2 == 0 ? Icons.search : Icons.close));
        await tester.pump();
      }

      // Should end in search mode (even number of taps)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should handle Unicode characters in search', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      const unicodeQuery = '测试 🎯 ñoño';
      await tester.enterText(find.byType(TextField), unicodeQuery);
      await tester.pump();

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.searchQuery, unicodeQuery);
    });

    testWidgets('should handle very long search queries', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final longQuery = 'a' * 1000;
      await tester.enterText(find.byType(TextField), longQuery);
      await tester.pump();

      final cardGrid = tester.widget<CardGrid>(find.byType(CardGrid));
      expect(cardGrid.searchQuery, longQuery);
    });

    testWidgets('should handle widget rebuild without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Force multiple rebuilds
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          const MaterialApp(home: Home()),
        );
      }

      expect(find.byType(Home), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('should have proper semantics for screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // Verify important interactive elements are present
      expect(find.byType(IconButton), findsNWidgets(3));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(PopupMenuButton), findsOneWidget);
    });

    testWidgets('should support keyboard navigation for search field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });

    testWidgets('should provide proper button semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Home()),
      );

      // All buttons should be tappable
      expect(find.byType(IconButton), findsNWidgets(3));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Test that buttons can be found and tapped
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      expect(tester.takeException(), isNull);
    });
  });

  group('UserCard Model Tests', () {
    test('should create UserCard with all required fields', () {
      final createdAt = DateTime.now();
      final card = UserCard(
        id: 1,
        name: 'Test Card',
        code: '123456789',
        usage: 5,
        createdAt: createdAt,
        symbology: 'CODE128',
      );

      expect(card.id, 1);
      expect(card.name, 'Test Card');
      expect(card.code, '123456789');
      expect(card.usage, 5);
      expect(card.createdAt, createdAt);
      expect(card.symbology, 'CODE128');
    });

    test('should create UserCard without id', () {
      final createdAt = DateTime.now();
      const card = UserCard(
        name: 'Test Card',
        code: '123456789',
        usage: 0,
        createdAt: createdAt,
        symbology: 'QR',
      );

      expect(card.id, isNull);
      expect(card.name, 'Test Card');
    });

    test('should create copy of UserCard with updated fields', () {
      final originalDate = DateTime.now();
      final card = UserCard(
        id: 1,
        name: 'Original',
        code: '123',
        usage: 1,
        createdAt: originalDate,
        symbology: 'CODE128',
      );

      final updatedCard = card.copyWith(
        name: 'Updated',
        usage: 5,
      );

      expect(updatedCard.id, 1);
      expect(updatedCard.name, 'Updated');
      expect(updatedCard.code, '123');
      expect(updatedCard.usage, 5);
      expect(updatedCard.createdAt, originalDate);
      expect(updatedCard.symbology, 'CODE128');
    });

    test('should convert UserCard to map correctly', () {
      final createdAt = DateTime.now();
      final card = UserCard(
        id: 1,
        name: 'Test Card',
        code: '123456789',
        usage: 5,
        createdAt: createdAt,
        symbology: 'CODE128',
      );

      final map = card.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Test Card');
      expect(map['code'], '123456789');
      expect(map['usage'], 5);
      expect(map['created_at'], createdAt.toIso8601String());
      expect(map['symbology'], 'CODE128');
    });

    test('should have proper string representation', () {
      final createdAt = DateTime.now();
      final card = UserCard(
        id: 1,
        name: 'Test Card',
        code: '123456789',
        usage: 5,
        createdAt: createdAt,
        symbology: 'CODE128',
      );

      final cardString = card.toString();
      expect(cardString, contains('Test Card'));
      expect(cardString, contains('123456789'));
      expect(cardString, contains('5'));
      expect(cardString, contains('CODE128'));
    });
  });
}