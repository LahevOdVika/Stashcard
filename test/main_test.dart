import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stashcard/main.dart';
import 'package:stashcard/providers/theme_provider.dart';
import 'package:stashcard/Views/home.dart';
import 'package:stashcard/Views/settings.dart';
import 'package:stashcard/destination.dart';

// Mock ThemeProvider for testing
class MockThemeProvider extends ChangeNotifier implements ThemeProvider {
  Color _seedColor = Colors.blue;
  ThemeMode _mode = ThemeMode.system;

  @override
  Color get seedColor => _seedColor;

  @override
  ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
  );

  @override
  ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
  );

  @override
  ThemeMode get themeMode => _mode;

  @override
  void setSeedColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }

  @override
  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}

void main() {
  group('StashcardApp Widget Tests', () {
    testWidgets('StashcardApp builds correctly with ThemeProvider', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: const StashcardApp(),
        ),
      );

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NavigationHandler), findsOneWidget);
    });

    testWidgets('StashcardApp uses correct theme configuration', (WidgetTester tester) async {
      // Arrange
      final mockThemeProvider = MockThemeProvider();
      
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: mockThemeProvider,
          child: const StashcardApp(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, equals(mockThemeProvider.lightTheme));
      expect(materialApp.darkTheme, equals(mockThemeProvider.darkTheme));
      expect(materialApp.themeMode, equals(mockThemeProvider.themeMode));
      expect(materialApp.home, isA<NavigationHandler>());
    });

    testWidgets('StashcardApp throws error when ThemeProvider is missing', (WidgetTester tester) async {
      // Act & Assert
      expect(() async {
        await tester.pumpWidget(const StashcardApp());
      }, throwsA(isA<ProviderNotFoundException>()));
    });

    testWidgets('StashcardApp responds to theme changes', (WidgetTester tester) async {
      // Arrange
      final mockThemeProvider = MockThemeProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: mockThemeProvider,
          child: const StashcardApp(),
        ),
      );

      // Act - Change theme
      mockThemeProvider.setSeedColor(Colors.red);
      await tester.pump();

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, 
             equals(ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.light).primary));
    });
  });

  group('NavigationHandler Widget Tests', () {
    Widget createTestableNavigationHandler() {
      return ChangeNotifierProvider<ThemeProvider>(
        create: (context) => MockThemeProvider(),
        child: MaterialApp(
          home: const NavigationHandler(),
        ),
      );
    }

    testWidgets('NavigationHandler builds with correct initial state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableNavigationHandler());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
      
      // Verify navigation destinations are present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('NavigationHandler has correct number of destinations', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableNavigationHandler());

      // Assert
      expect(find.byType(NavigationDestination), findsNWidgets(2));
    });

    testWidgets('NavigationHandler navigation switches views correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableNavigationHandler());

      // Assert initial state
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);

      // Act - Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Assert Settings view is shown
      expect(find.byType(Home), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);

      // Act - Navigate back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Assert Home view is shown again
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('NavigationHandler selectedIndex updates correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableNavigationHandler());

      // Assert initial selectedIndex
      var navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, equals(0));

      // Act - Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Assert selectedIndex updated
      navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, equals(1));

      // Act - Navigate back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Assert selectedIndex back to 0
      navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, equals(0));
    });

    testWidgets('NavigationHandler destinations have correct icons and labels', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestableNavigationHandler());

      // Assert
      final destinations = tester.widgetList<NavigationDestination>(find.byType(NavigationDestination)).toList();
      
      // Verify Home destination
      final homeDestination = destinations[0];
      expect((homeDestination.icon as Icon).icon, equals(Icons.home_outlined));
      expect((homeDestination.selectedIcon as Icon).icon, equals(Icons.home));
      expect(homeDestination.label, equals('Home'));

      // Verify Settings destination
      final settingsDestination = destinations[1];
      expect((settingsDestination.icon as Icon).icon, equals(Icons.settings_outlined));
      expect((settingsDestination.selectedIcon as Icon).icon, equals(Icons.settings));
      expect(settingsDestination.label, equals('Settings'));
    });

    testWidgets('NavigationHandler maintains correct route-destination mapping', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableNavigationHandler());

      // Get the state to verify internal structure
      final state = tester.state<_NavigationHandlerState>(find.byType(NavigationHandler));
      
      // Assert destinations and routes alignment
      expect(state.destinations.length, equals(state.routes.length));
      expect(state.destinations.length, equals(2));
      
      // Verify destination properties
      expect(state.destinations[0].index, equals(0));
      expect(state.destinations[0].title, equals('Home'));
      expect(state.destinations[1].index, equals(1));
      expect(state.destinations[1].title, equals('Settings'));
      
      // Verify routes
      expect(state.routes[0], isA<Home>());
      expect(state.routes[1], isA<SettingsPage>());
    });
  });

  group('_NavigationHandlerState Internal Tests', () {
    testWidgets('_changeDestination method updates state correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: MaterialApp(home: const NavigationHandler()),
        ),
      );

      final state = tester.state<_NavigationHandlerState>(find.byType(NavigationHandler));
      
      // Assert initial state
      expect(state._selectedIndex, equals(0));

      // Act - Simulate navigation change through UI
      await tester.tap(find.text('Settings'));
      await tester.pump();

      // Assert state changed
      expect(state._selectedIndex, equals(1));
    });

    testWidgets('routes list contains correct widget instances', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: MaterialApp(home: const NavigationHandler()),
        ),
      );

      final state = tester.state<_NavigationHandlerState>(find.byType(NavigationHandler));
      
      // Assert routes configuration
      expect(state.routes.length, equals(2));
      expect(state.routes[0].runtimeType, equals(Home));
      expect(state.routes[1].runtimeType, equals(SettingsPage));
    });

    testWidgets('destinations list is properly configured', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: MaterialApp(home: const NavigationHandler()),
        ),
      );

      final state = tester.state<_NavigationHandlerState>(find.byType(NavigationHandler));
      
      // Assert destinations configuration
      expect(state.destinations.length, equals(2));
      
      final homeDestination = state.destinations[0];
      expect(homeDestination.index, equals(0));
      expect(homeDestination.title, equals('Home'));
      expect(homeDestination.icon, equals(Icons.home_outlined));
      expect(homeDestination.selectedIcon, equals(Icons.home));
      
      final settingsDestination = state.destinations[1];
      expect(settingsDestination.index, equals(1));
      expect(settingsDestination.title, equals('Settings'));
      expect(settingsDestination.icon, equals(Icons.settings_outlined));
      expect(settingsDestination.selectedIcon, equals(Icons.settings));
    });
  });

  group('Integration Tests', () {
    testWidgets('Complete app flow works end-to-end', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: const StashcardApp(),
        ),
      );

      // Assert initial app state
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NavigationHandler), findsOneWidget);
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Act - Test complete navigation flow
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(Home), findsNothing);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('App handles rapid navigation changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: MaterialApp(home: const NavigationHandler()),
        ),
      );

      // Act - Perform rapid navigation switches
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsPage), findsOneWidget);

        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(find.byType(Home), findsOneWidget);
      }
    });

    testWidgets('App maintains consistent state during theme changes', (WidgetTester tester) async {
      // Arrange
      final themeProvider = MockThemeProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: const StashcardApp(),
        ),
      );

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      // Act - Change theme while on Settings page
      themeProvider.setThemeMode(ThemeMode.dark);
      await tester.pump();

      // Assert - Should still be on Settings page
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(Home), findsNothing);
      
      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, equals(1));
    });
  });

  group('Edge Case Tests', () {
    testWidgets('NavigationHandler handles widget rebuilds gracefully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: MaterialApp(home: const NavigationHandler()),
        ),
      );

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Act - Force multiple rebuilds
      for (int i = 0; i < 3; i++) {
        await tester.pump();
      }
      
      // Assert - Should maintain Settings state
      expect(find.byType(SettingsPage), findsOneWidget);
      final navigationBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, equals(1));
    });

    testWidgets('App handles provider updates during navigation', (WidgetTester tester) async {
      // Arrange
      final themeProvider = MockThemeProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: const StashcardApp(),
        ),
      );

      // Act - Change theme and navigate simultaneously
      themeProvider.setSeedColor(Colors.purple);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Assert - Both operations should succeed
      expect(find.byType(SettingsPage), findsOneWidget);
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, 
             equals(ColorScheme.fromSeed(seedColor: Colors.purple, brightness: Brightness.light).primary));
    });

    testWidgets('NavigationHandler maintains state consistency', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: MaterialApp(home: const NavigationHandler()),
        ),
      );

      final state = tester.state<_NavigationHandlerState>(find.byType(NavigationHandler));

      // Act & Assert - Verify state consistency after multiple operations
      expect(state._selectedIndex, equals(0));
      expect(state.destinations.length, equals(2));
      expect(state.routes.length, equals(2));

      // Navigate and verify state
      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(state._selectedIndex, equals(1));

      // Return and verify state
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(state._selectedIndex, equals(0));
    });
  });

  group('Performance and Memory Tests', () {
    testWidgets('NavigationHandler does not leak widgets during navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: MaterialApp(home: const NavigationHandler()),
        ),
      );

      // Act - Navigate multiple times to test for widget leaks
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
      }

      // Assert - Should still have exactly one of each widget type
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App handles multiple provider notifications efficiently', (WidgetTester tester) async {
      // Arrange
      final themeProvider = MockThemeProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: const StashcardApp(),
        ),
      );

      // Act - Trigger multiple rapid provider updates
      for (int i = 0; i < 5; i++) {
        themeProvider.setSeedColor(Color(0xFF000000 + i * 0x111111));
        await tester.pump(const Duration(milliseconds: 10));
      }

      // Assert - App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NavigationHandler), findsOneWidget);
      expect(find.byType(Home), findsOneWidget);
    });
  });

  group('Destination Class Tests', () {
    test('Destination class creates instances with correct properties', () {
      // Arrange & Act
      const destination = Destination(0, "Test", Icons.star, Icons.star_filled);
      
      // Assert
      expect(destination.index, equals(0));
      expect(destination.title, equals("Test"));
      expect(destination.icon, equals(Icons.star));
      expect(destination.selectedIcon, equals(Icons.star_filled));
    });

    test('Destination class handles different icon types', () {
      // Arrange & Act
      const homeDestination = Destination(0, "Home", Icons.home_outlined, Icons.home);
      const settingsDestination = Destination(1, "Settings", Icons.settings_outlined, Icons.settings);
      
      // Assert
      expect(homeDestination.icon, equals(Icons.home_outlined));
      expect(homeDestination.selectedIcon, equals(Icons.home));
      expect(settingsDestination.icon, equals(Icons.settings_outlined));
      expect(settingsDestination.selectedIcon, equals(Icons.settings));
    });
  });

  group('Main Function Tests', () {
    testWidgets('main function initializes app correctly', (WidgetTester tester) async {
      // Note: Testing main() directly is challenging in widget tests
      // Instead, we test the structure it creates
      
      // Act - Create the same structure as main()
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => MockThemeProvider(),
          child: const StashcardApp(),
        ),
      );

      // Assert - Verify the expected widget tree structure
      expect(find.byType(ChangeNotifierProvider<ThemeProvider>), findsOneWidget);
      expect(find.byType(StashcardApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NavigationHandler), findsOneWidget);
    });
  });

  group('Constructor Tests', () {
    testWidgets('StashcardApp constructor works with key parameter', (WidgetTester tester) async {
      // Arrange
      const testKey = Key('test_stashcard_app');
      
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: const StashcardApp(key: testKey),
        ),
      );

      // Assert
      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets('NavigationHandler constructor works with default parameters', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => MockThemeProvider(),
          child: MaterialApp(home: const NavigationHandler()),
        ),
      );

      // Assert - Should build without issues
      expect(find.byType(NavigationHandler), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}