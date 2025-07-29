import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stashcard/Views/settings.dart';
import 'package:stashcard/Views/home.dart';
import '../lib/destination.dart'; // Adjust import path as needed

void main() {
  group('Destination', () {
    testWidgets('should create Destination with all required properties', (WidgetTester tester) async {
      // Arrange
      const index = 0;
      const title = 'Home';
      const icon = Icons.home;
      const selectedIcon = Icons.home_filled;

      // Act
      const destination = Destination(index, title, icon, selectedIcon);

      // Assert
      expect(destination.index, equals(index));
      expect(destination.title, equals(title));
      expect(destination.icon, equals(icon));
      expect(destination.selectedIcon, equals(selectedIcon));
    });

    test('should create Destination with different index values', () {
      // Test different index values
      const destinations = [
        Destination(0, 'Home', Icons.home, Icons.home_filled),
        Destination(1, 'Settings', Icons.settings, Icons.settings_filled),
        Destination(2, 'Profile', Icons.person, Icons.person_filled),
        Destination(-1, 'Invalid', Icons.error, Icons.error_outline),
      ];

      expect(destinations[0].index, equals(0));
      expect(destinations[1].index, equals(1));
      expect(destinations[2].index, equals(2));
      expect(destinations[3].index, equals(-1));
    });

    test('should handle empty and special character titles', () {
      const destinations = [
        Destination(0, '', Icons.home, Icons.home_filled),
        Destination(1, 'Title with spaces', Icons.settings, Icons.settings_filled),
        Destination(2, 'Title_with_underscores', Icons.person, Icons.person_filled),
        Destination(3, 'Title-with-dashes', Icons.star, Icons.star_filled),
        Destination(4, 'Title with émojis 🏠', Icons.emoji_emotions, Icons.emoji_emotions_outlined),
      ];

      expect(destinations[0].title, equals(''));
      expect(destinations[1].title, equals('Title with spaces'));
      expect(destinations[2].title, equals('Title_with_underscores'));
      expect(destinations[3].title, equals('Title-with-dashes'));
      expect(destinations[4].title, equals('Title with émojis 🏠'));
    });

    test('should handle different icon combinations', () {
      const destination1 = Destination(0, 'Same Icons', Icons.home, Icons.home);
      const destination2 = Destination(1, 'Different Icons', Icons.home, Icons.home_filled);
      const destination3 = Destination(2, 'Custom Icons', Icons.star, Icons.favorite);

      expect(destination1.icon, equals(destination1.selectedIcon));
      expect(destination2.icon, isNot(equals(destination2.selectedIcon)));
      expect(destination3.icon, equals(Icons.star));
      expect(destination3.selectedIcon, equals(Icons.favorite));
    });
  });

  group('DestinationView', () {
    testWidgets('should create DestinationView with required parameters', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const navigatorKey = Key('test_navigator');

      // Act
      const widget = DestinationView(
        destination: destination,
        navigatorKey: navigatorKey,
      );

      // Assert
      expect(widget.destination, equals(destination));
      expect(widget.navigatorKey, equals(navigatorKey));
    });

    testWidgets('should build Navigator with correct key', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const navigatorKey = Key('test_navigator');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Assert
      final navigator = tester.widget<Navigator>(find.byType(Navigator));
      expect(navigator.key, equals(navigatorKey));
    });

    testWidgets('should navigate to Home when destination index is 0', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const navigatorKey = Key('test_navigator');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Assert
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('should navigate to SettingsPage when destination index is 1', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(1, 'Settings', Icons.settings, Icons.settings_filled);
      const navigatorKey = Key('test_navigator');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Assert
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(Home), findsNothing);
    });

    testWidgets('should return SizedBox for invalid destination index', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(2, 'Invalid', Icons.error, Icons.error_outline);
      const navigatorKey = Key('test_navigator');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Assert
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Home), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('should return SizedBox for negative destination index', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(-1, 'Negative', Icons.error, Icons.error_outline);
      const navigatorKey = Key('test_navigator');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Assert
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Home), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('should handle route settings correctly', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const navigatorKey = Key('test_navigator');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Assert
      final navigator = tester.widget<Navigator>(find.byType(Navigator));
      expect(navigator.onGenerateRoute, isNotNull);
    });

    testWidgets('should create MaterialPageRoute with correct settings', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const navigatorKey = Key('test_navigator');

      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Act - trigger route generation
      final navigator = tester.widget<Navigator>(find.byType(Navigator));
      const routeSettings = RouteSettings(name: '/');
      final route = navigator.onGenerateRoute!(routeSettings);

      // Assert
      expect(route, isA<MaterialPageRoute>());
      expect(route?.settings, equals(routeSettings));
    });

    testWidgets('should handle null route settings gracefully', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const navigatorKey = Key('test_navigator');

      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Act - trigger route generation with null name
      final navigator = tester.widget<Navigator>(find.byType(Navigator));
      const routeSettings = RouteSettings(name: null);
      final route = navigator.onGenerateRoute!(routeSettings);

      // Assert
      expect(route, isA<MaterialPageRoute>());
      expect(route?.settings, equals(routeSettings));
    });

    testWidgets('should handle custom route names', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const navigatorKey = Key('test_navigator');

      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Act - trigger route generation with custom name
      final navigator = tester.widget<Navigator>(find.byType(Navigator));
      const routeSettings = RouteSettings(name: '/custom');
      final route = navigator.onGenerateRoute!(routeSettings);

      // Assert
      expect(route, isA<MaterialPageRoute>());
      final materialRoute = route as MaterialPageRoute;
      final widget = materialRoute.builder(tester.element(find.byType(MaterialApp)));
      expect(widget, isA<SizedBox>());
    });

    testWidgets('should maintain state across rebuilds', (WidgetTester tester) async {
      // Arrange
      const destination1 = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const destination2 = Destination(1, 'Settings', Icons.settings, Icons.settings_filled);
      const navigatorKey = Key('test_navigator');

      // Act - Initial build
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination1,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      expect(find.byType(Home), findsOneWidget);

      // Act - Rebuild with different destination
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination2,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      // Assert
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(Home), findsNothing);
    });

    testWidgets('should work with different navigator keys', (WidgetTester tester) async {
      // Arrange
      const destination = Destination(0, 'Home', Icons.home, Icons.home_filled);
      const navigatorKey1 = Key('test_navigator_1');
      const navigatorKey2 = Key('test_navigator_2');

      // Act & Assert - First navigator key
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey1,
          ),
        ),
      );

      var navigator = tester.widget<Navigator>(find.byType(Navigator));
      expect(navigator.key, equals(navigatorKey1));

      // Act & Assert - Second navigator key
      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination,
            navigatorKey: navigatorKey2,
          ),
        ),
      );

      navigator = tester.widget<Navigator>(find.byType(Navigator));
      expect(navigator.key, equals(navigatorKey2));
    });

    testWidgets('should handle extreme index values', (WidgetTester tester) async {
      // Test with very large positive index
      const destination1 = Destination(999999, 'Large Index', Icons.error, Icons.error_outline);
      const navigatorKey = Key('test_navigator');

      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination1,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);

      // Test with very large negative index
      const destination2 = Destination(-999999, 'Large Negative Index', Icons.error, Icons.error_outline);

      await tester.pumpWidget(
        MaterialApp(
          home: const DestinationView(
            destination: destination2,
            navigatorKey: navigatorKey,
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    group('Edge Cases', () {
      testWidgets('should handle destination with same icon and selectedIcon', (WidgetTester tester) async {
        // Arrange
        const destination = Destination(0, 'Home', Icons.home, Icons.home);
        const navigatorKey = Key('test_navigator');

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: const DestinationView(
              destination: destination,
              navigatorKey: navigatorKey,
            ),
          ),
        );

        // Assert
        expect(find.byType(Home), findsOneWidget);
        expect(destination.icon, equals(destination.selectedIcon));
      });

      testWidgets('should handle destination with empty title', (WidgetTester tester) async {
        // Arrange
        const destination = Destination(0, '', Icons.home, Icons.home_filled);
        const navigatorKey = Key('test_navigator');

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: const DestinationView(
              destination: destination,
              navigatorKey: navigatorKey,
            ),
          ),
        );

        // Assert
        expect(find.byType(Home), findsOneWidget);
        expect(destination.title, equals(''));
      });

      testWidgets('should handle unicode characters in title', (WidgetTester tester) async {
        // Arrange
        const destination = Destination(0, '🏠 Hôme 测试', Icons.home, Icons.home_filled);
        const navigatorKey = Key('test_navigator');

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: const DestinationView(
              destination: destination,
              navigatorKey: navigatorKey,
            ),
          ),
        );

        // Assert
        expect(find.byType(Home), findsOneWidget);
        expect(destination.title, equals('🏠 Hôme 测试'));
      });
    });
  });
}