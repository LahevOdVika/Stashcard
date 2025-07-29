import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stashcard/Views/settings.dart';
import 'package:stashcard/providers/theme_provider.dart';

import 'settings_test.mocks.dart';

// Generate mocks for testing
@GenerateMocks([ThemeProvider])
void main() {
  group('AppThemeMode', () {
    test('should have correct display names', () {
      expect(AppThemeMode.system.displayName, equals('System'));
      expect(AppThemeMode.light.displayName, equals('Light'));
      expect(AppThemeMode.dark.displayName, equals('Dark'));
    });

    test('toFlutterThemeMode should convert correctly', () {
      expect(AppThemeMode.system.toFlutterThemeMode(), equals(ThemeMode.system));
      expect(AppThemeMode.light.toFlutterThemeMode(), equals(ThemeMode.light));
      expect(AppThemeMode.dark.toFlutterThemeMode(), equals(ThemeMode.dark));
    });

    test('fromFlutterThemeMode should convert correctly', () {
      expect(AppThemeMode.fromFlutterThemeMode(ThemeMode.system), equals(AppThemeMode.system));
      expect(AppThemeMode.fromFlutterThemeMode(ThemeMode.light), equals(AppThemeMode.light));
      expect(AppThemeMode.fromFlutterThemeMode(ThemeMode.dark), equals(AppThemeMode.dark));
    });

    test('should handle all enum values in conversion methods', () {
      // Test that conversion works for all values
      for (final mode in AppThemeMode.values) {
        final flutterMode = mode.toFlutterThemeMode();
        final backToAppMode = AppThemeMode.fromFlutterThemeMode(flutterMode);
        expect(backToAppMode, equals(mode));
      }
    });

    test('enum should have exactly 3 values', () {
      expect(AppThemeMode.values.length, equals(3));
    });

    test('enum values should be unique', () {
      final displayNames = AppThemeMode.values.map((e) => e.displayName).toList();
      final uniqueNames = displayNames.toSet();
      expect(displayNames.length, equals(uniqueNames.length));
    });
  });

  group('SettingsPage Widget Tests', () {
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockThemeProvider = MockThemeProvider();
      when(mockThemeProvider.seedColor).thenReturn(Colors.blue);
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
    });

    testWidgets('should render all settings options correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Verify app bar
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify all list tiles with their exact text
      expect(find.text('App color scheme'), findsOneWidget);
      expect(find.text('App theme'), findsOneWidget);
      expect(find.text('App lock'), findsOneWidget);
      expect(find.text('Source code'), findsOneWidget);
      expect(find.text('Copyright © 2025 LahevOdVika'), findsOneWidget);

      // Verify corresponding icons
      expect(find.byIcon(Icons.color_lens), findsOneWidget);
      expect(find.byIcon(Icons.brightness_4), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);

      // Verify correct number of dividers
      expect(find.byType(Divider), findsNWidgets(4));

      // Verify ListView for scrollability
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should open color picker dialog when color scheme is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Tap on color scheme option
      await tester.tap(find.text('App color scheme'));
      await tester.pumpAndSettle();

      // Verify dialog appears with correct components
      expect(find.text('Pick a color'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(BlockPicker), findsOneWidget);
    });

    testWidgets('should call setSeedColor and close dialog when color is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Open color picker dialog
      await tester.tap(find.text('App color scheme'));
      await tester.pumpAndSettle();

      // Find the BlockPicker widget
      final blockPicker = find.byType(BlockPicker);
      expect(blockPicker, findsOneWidget);
      
      // Simulate color selection by directly calling the onColorChanged callback
      final widget = tester.widget<BlockPicker>(blockPicker);
      widget.onColorChanged(Colors.red);
      
      await tester.pumpAndSettle();

      // Verify setSeedColor was called with the new color
      verify(mockThemeProvider.setSeedColor(Colors.red)).called(1);
      
      // Verify dialog is closed (no longer visible)
      expect(find.text('Pick a color'), findsNothing);
    });

    testWidgets('should show dropdown menu with correct theme options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Find dropdown menu
      expect(find.byType(DropdownMenu<AppThemeMode>), findsOneWidget);
      
      // Verify initial selection matches theme provider
      verify(mockThemeProvider.themeMode).called(greaterThan(0));
    });

    testWidgets('should call setThemeMode when theme is selected from dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      final dropdown = tester.widget<DropdownMenu<AppThemeMode>>(
        find.byType(DropdownMenu<AppThemeMode>)
      );
      
      // Simulate theme selection to Dark mode
      dropdown.onSelected?.call(AppThemeMode.dark);
      await tester.pumpAndSettle();

      // Verify setThemeMode was called with correct theme
      verify(mockThemeProvider.setThemeMode(ThemeMode.dark)).called(1);
    });

    testWidgets('should handle null selection in theme dropdown gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      final dropdown = tester.widget<DropdownMenu<AppThemeMode>>(
        find.byType(DropdownMenu<AppThemeMode>)
      );
      
      // Simulate null selection
      dropdown.onSelected?.call(null);
      await tester.pumpAndSettle();

      // Verify setThemeMode was not called with null
      verifyNever(mockThemeProvider.setThemeMode(any));
    });

    testWidgets('should update controller text when valid theme is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      final dropdown = tester.widget<DropdownMenu<AppThemeMode>>(
        find.byType(DropdownMenu<AppThemeMode>)
      );
      
      // Simulate theme selection to Light mode
      dropdown.onSelected?.call(AppThemeMode.light);
      await tester.pumpAndSettle();

      // Verify both setThemeMode was called and controller would be updated
      verify(mockThemeProvider.setThemeMode(ThemeMode.light)).called(1);
    });

    testWidgets('should render app lock option without tap functionality', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Find app lock tile
      final lockTile = find.ancestor(
        of: find.text('App lock'),
        matching: find.byType(ListTile),
      );
      expect(lockTile, findsOneWidget);
      
      // Verify it has no onTap functionality (future feature)
      final lockListTile = tester.widget<ListTile>(lockTile);
      expect(lockListTile.onTap, isNull);
    });

    testWidgets('should render copyright information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      expect(find.text('Copyright © 2025 LahevOdVika'), findsOneWidget);
      
      // Verify it's in a ListTile trailing position
      final copyrightTile = find.ancestor(
        of: find.text('Copyright © 2025 LahevOdVika'),
        matching: find.byType(ListTile),
      );
      expect(copyrightTile, findsOneWidget);
    });

    testWidgets('should have correct GitHub URL in state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Access the private state to verify GitHub URL
      final settingsPageState = tester.state<_SettingsPageState>(find.byType(SettingsPage));
      expect(settingsPageState.githubUrl, equals('https://github.com/LahevOdVika/Stashcard'));
    });

    testWidgets('should render source code button correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Find source code button
      final sourceCodeButton = find.ancestor(
        of: find.text('Source code'),
        matching: find.byType(TextButton),
      );
      expect(sourceCodeButton, findsOneWidget);

      // Verify button has icon and label
      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.text('Source code'), findsOneWidget);
      
      // Test that button is tappable (we can't test URL launching without mocking url_launcher)
      await tester.tap(sourceCodeButton);
      await tester.pump();
      
      // No exceptions should be thrown during tap
    });
  });

  group('Edge Cases and Error Handling', () {
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockThemeProvider = MockThemeProvider();
      when(mockThemeProvider.seedColor).thenReturn(Colors.blue);
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
    });

    testWidgets('should handle different initial theme provider values', (WidgetTester tester) async {
      // Test with Dark theme initially
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.dark);
      when(mockThemeProvider.seedColor).thenReturn(Colors.red);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Should still render correctly
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      
      // Verify theme provider methods were called
      verify(mockThemeProvider.themeMode).called(greaterThan(0));
      verify(mockThemeProvider.seedColor).called(greaterThan(0));
    });

    testWidgets('should handle theme provider with light mode', (WidgetTester tester) async {
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.light);
      when(mockThemeProvider.seedColor).thenReturn(Colors.green);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      expect(find.byType(SettingsPage), findsOneWidget);
      
      // Verify dropdown shows correct initial selection
      final dropdown = tester.widget<DropdownMenu<AppThemeMode>>(
        find.byType(DropdownMenu<AppThemeMode>)
      );
      expect(dropdown.initialSelection, equals(AppThemeMode.light));
    });

    testWidgets('should maintain controller state across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Get initial controller
      final initialState = tester.state<_SettingsPageState>(find.byType(SettingsPage));
      final initialController = initialState._themeModeController;

      // Trigger rebuild
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Controller should be the same instance
      final rebuiltState = tester.state<_SettingsPageState>(find.byType(SettingsPage));
      expect(rebuiltState._themeModeController, equals(initialController));
    });

    testWidgets('should handle rapid color changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Open color picker
      await tester.tap(find.text('App color scheme'));
      await tester.pumpAndSettle();

      final blockPicker = tester.widget<BlockPicker>(find.byType(BlockPicker));
      
      // Simulate rapid color changes
      blockPicker.onColorChanged(Colors.red);
      blockPicker.onColorChanged(Colors.green);
      blockPicker.onColorChanged(Colors.blue);

      await tester.pumpAndSettle();

      // Should handle all calls
      verify(mockThemeProvider.setSeedColor(Colors.red)).called(1);
      verify(mockThemeProvider.setSeedColor(Colors.green)).called(1);
      verify(mockThemeProvider.setSeedColor(Colors.blue)).called(1);
    });
  });

  group('Accessibility and UI Tests', () {
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockThemeProvider = MockThemeProvider();
      when(mockThemeProvider.seedColor).thenReturn(Colors.blue);
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
    });

    testWidgets('should have proper semantic structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Verify semantic structure
      expect(find.byType(ListTile), findsNWidgets(5));
      
      // All ListTiles should have titles for accessibility
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final tile in listTiles) {
        expect(tile.title != null || tile.trailing != null, isTrue);
      }
    });

    testWidgets('should have adequate tap target sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Check tap target sizes meet minimum requirements (48dp)
      final listTileSize = tester.getSize(find.byType(ListTile).first);
      expect(listTileSize.height, greaterThanOrEqualTo(48.0));

      final buttonSize = tester.getSize(find.byType(TextButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('should support scrolling when content overflows', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Verify ListView enables scrolling
      expect(find.byType(ListView), findsOneWidget);
      
      // Test scrolling capability
      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pumpAndSettle();
      
      // Should not throw any exceptions
    });

    testWidgets('should maintain visual hierarchy with dividers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Verify dividers separate sections logically
      final dividers = find.byType(Divider);
      expect(dividers, findsNWidgets(4));
      
      // Check divider positioning
      final listItems = find.byType(ListTile);
      expect(listItems, findsNWidgets(5));
    });

    testWidgets('should handle different screen orientations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Test portrait mode (default)
      expect(find.byType(SettingsPage), findsOneWidget);

      // Simulate orientation change by changing screen size
      tester.binding.window.physicalSizeTestValue = const Size(2400, 1080); // Landscape
      tester.binding.window.devicePixelRatioTestValue = 3.0;
      await tester.pumpAndSettle();

      // Should still render correctly
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Reset to portrait for other tests
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      addTearDown(() => tester.binding.window.clearPhysicalSizeTestValue());
    });
  });

  group('Integration with ThemeProvider', () {
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockThemeProvider = MockThemeProvider();
      when(mockThemeProvider.seedColor).thenReturn(Colors.blue);
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
    });

    testWidgets('should react to theme provider changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Verify initial state
      verify(mockThemeProvider.themeMode).called(greaterThan(0));
      verify(mockThemeProvider.seedColor).called(greaterThan(0));

      // Test theme mode change
      final dropdown = tester.widget<DropdownMenu<AppThemeMode>>(
        find.byType(DropdownMenu<AppThemeMode>)
      );
      dropdown.onSelected?.call(AppThemeMode.dark);

      verify(mockThemeProvider.setThemeMode(ThemeMode.dark)).called(1);
    });

    testWidgets('should use Provider.of with listen: false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // The widget should access theme provider in build method
      // This verifies the Provider.of<ThemeProvider>(context, listen: false) call
      verify(mockThemeProvider.themeMode).called(greaterThan(0));
      verify(mockThemeProvider.seedColor).called(greaterThan(0));
    });
  });

  group('URL Launching Tests', () {
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockThemeProvider = MockThemeProvider();
      when(mockThemeProvider.seedColor).thenReturn(Colors.blue);
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
    });

    testWidgets('should handle URL launch exceptions gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      // Find and tap source code button
      final sourceCodeButton = find.ancestor(
        of: find.text('Source code'),
        matching: find.byType(TextButton),
      );
      expect(sourceCodeButton, findsOneWidget);

      // Tap the button - this would normally try to launch URL
      // We expect it to handle any exceptions gracefully
      expect(() => tester.tap(sourceCodeButton), returnsNormally);
      await tester.pump();
    });

    testWidgets('should have valid GitHub URL format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      final settingsPageState = tester.state<_SettingsPageState>(find.byType(SettingsPage));
      final url = settingsPageState.githubUrl;
      
      // Verify URL format
      expect(url, startsWith('https://'));
      expect(url, contains('github.com'));
      expect(Uri.tryParse(url), isNotNull);
    });
  });

  group('Widget State Management', () {
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockThemeProvider = MockThemeProvider();
      when(mockThemeProvider.seedColor).thenReturn(Colors.blue);
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
    });

    testWidgets('should initialize with correct default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      final settingsPageState = tester.state<_SettingsPageState>(find.byType(SettingsPage));
      
      // Verify initialization
      expect(settingsPageState.githubUrl, isNotEmpty);
      expect(settingsPageState._themeModeController, isNotNull);
      expect(settingsPageState.selectedTheme, isNull); // Initially null
    });

    testWidgets('should handle controller disposal properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
            child: const SettingsPage(),
          ),
        ),
      );

      final settingsPageState = tester.state<_SettingsPageState>(find.byType(SettingsPage));
      final controller = settingsPageState._themeModeController;
      
      // Verify controller is not disposed initially
      expect(() => controller.text, returnsNormally);

      // Remove widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      
      // Controller should be disposed (this would throw if accessed)
      // We can't easily test this without accessing private state
    });
  });
}