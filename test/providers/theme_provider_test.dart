import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the ThemeProvider class
import '../../lib/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    group('initialization', () {
      test('should initialize with default green seed color', () {
        expect(themeProvider.seedColor, equals(Colors.green));
      });

      test('should initialize with system theme mode', () {
        expect(themeProvider.themeMode, equals(ThemeMode.system));
      });

      test('should be instance of ChangeNotifier', () {
        expect(themeProvider, isA<ChangeNotifier>());
      });
    });

    group('seedColor getter', () {
      test('should return current seed color', () {
        expect(themeProvider.seedColor, equals(Colors.green));
      });

      test('should return updated seed color after change', () {
        themeProvider.setSeedColor(Colors.blue);
        expect(themeProvider.seedColor, equals(Colors.blue));
      });
    });

    group('lightTheme getter', () {
      test('should return ThemeData with light brightness', () {
        final theme = themeProvider.lightTheme;
        
        expect(theme, isA<ThemeData>());
        expect(theme.colorScheme.brightness, equals(Brightness.light));
      });

      test('should use current seed color for light theme', () {
        themeProvider.setSeedColor(Colors.red);
        final theme = themeProvider.lightTheme;
        
        expect(theme.colorScheme.brightness, equals(Brightness.light));
        // Verify the theme uses the red seed color by checking primary color derivation
        expect(theme.colorScheme.primary, isNotNull);
      });

      test('should generate different themes for different seed colors', () {
        final greenTheme = themeProvider.lightTheme;
        
        themeProvider.setSeedColor(Colors.blue);
        final blueTheme = themeProvider.lightTheme;
        
        expect(greenTheme.colorScheme.primary, isNot(equals(blueTheme.colorScheme.primary)));
      });

      test('should always return light brightness regardless of seed color', () {
        final colors = [Colors.red, Colors.blue, Colors.purple, Colors.orange];
        
        for (final color in colors) {
          themeProvider.setSeedColor(color);
          final theme = themeProvider.lightTheme;
          expect(theme.colorScheme.brightness, equals(Brightness.light));
        }
      });
    });

    group('darkTheme getter', () {
      test('should return ThemeData with dark brightness', () {
        final theme = themeProvider.darkTheme;
        
        expect(theme, isA<ThemeData>());
        expect(theme.colorScheme.brightness, equals(Brightness.dark));
      });

      test('should use current seed color for dark theme', () {
        themeProvider.setSeedColor(Colors.purple);
        final theme = themeProvider.darkTheme;
        
        expect(theme.colorScheme.brightness, equals(Brightness.dark));
        expect(theme.colorScheme.primary, isNotNull);
      });

      test('should generate different themes for different seed colors', () {
        final greenTheme = themeProvider.darkTheme;
        
        themeProvider.setSeedColor(Colors.yellow);
        final yellowTheme = themeProvider.darkTheme;
        
        expect(greenTheme.colorScheme.primary, isNot(equals(yellowTheme.colorScheme.primary)));
      });

      test('should always return dark brightness regardless of seed color', () {
        final colors = [Colors.teal, Colors.pink, Colors.indigo, Colors.amber];
        
        for (final color in colors) {
          themeProvider.setSeedColor(color);
          final theme = themeProvider.darkTheme;
          expect(theme.colorScheme.brightness, equals(Brightness.dark));
        }
      });
    });

    group('themeMode getter', () {
      test('should return current theme mode', () {
        expect(themeProvider.themeMode, equals(ThemeMode.system));
      });

      test('should return updated theme mode after change', () {
        themeProvider.setThemeMode(ThemeMode.dark);
        expect(themeProvider.themeMode, equals(ThemeMode.dark));
      });
    });

    group('setSeedColor method', () {
      test('should update seed color', () {
        themeProvider.setSeedColor(Colors.red);
        expect(themeProvider.seedColor, equals(Colors.red));
      });

      test('should notify listeners when seed color changes', () {
        bool notified = false;
        themeProvider.addListener(() {
          notified = true;
        });

        themeProvider.setSeedColor(Colors.blue);
        expect(notified, isTrue);
      });

      test('should notify listeners even when setting same color', () {
        themeProvider.setSeedColor(Colors.orange);
        
        bool notified = false;
        themeProvider.addListener(() {
          notified = true;
        });

        themeProvider.setSeedColor(Colors.orange);
        expect(notified, isTrue);
      });

      test('should accept all valid Color values', () {
        final testColors = [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
          Colors.pink,
          Colors.teal,
          Colors.indigo,
          Colors.cyan,
          Colors.amber,
          Colors.lime,
          const Color(0xFF123456), // Custom hex color
          const Color.fromARGB(255, 100, 150, 200), // Custom ARGB color
          const Color.fromRGBO(50, 100, 150, 0.8), // Custom RGBO color
        ];

        for (final color in testColors) {
          expect(() => themeProvider.setSeedColor(color), returnsNormally);
          expect(themeProvider.seedColor, equals(color));
        }
      });

      test('should update both light and dark themes when seed color changes', () {
        final originalLightPrimary = themeProvider.lightTheme.colorScheme.primary;
        final originalDarkPrimary = themeProvider.darkTheme.colorScheme.primary;

        themeProvider.setSeedColor(Colors.deepPurple);

        final newLightPrimary = themeProvider.lightTheme.colorScheme.primary;
        final newDarkPrimary = themeProvider.darkTheme.colorScheme.primary;

        expect(newLightPrimary, isNot(equals(originalLightPrimary)));
        expect(newDarkPrimary, isNot(equals(originalDarkPrimary)));
      });
    });

    group('setThemeMode method', () {
      test('should update theme mode', () {
        themeProvider.setThemeMode(ThemeMode.light);
        expect(themeProvider.themeMode, equals(ThemeMode.light));
      });

      test('should notify listeners when theme mode changes', () {
        bool notified = false;
        themeProvider.addListener(() {
          notified = true;
        });

        themeProvider.setThemeMode(ThemeMode.dark);
        expect(notified, isTrue);
      });

      test('should notify listeners even when setting same mode', () {
        themeProvider.setThemeMode(ThemeMode.light);
        
        bool notified = false;
        themeProvider.addListener(() {
          notified = true;
        });

        themeProvider.setThemeMode(ThemeMode.light);
        expect(notified, isTrue);
      });

      test('should accept all ThemeMode values', () {
        final themeModes = [
          ThemeMode.system,
          ThemeMode.light,
          ThemeMode.dark,
        ];

        for (final mode in themeModes) {
          expect(() => themeProvider.setThemeMode(mode), returnsNormally);
          expect(themeProvider.themeMode, equals(mode));
        }
      });
    });

    group('ChangeNotifier behavior', () {
      test('should support multiple listeners', () {
        int listener1Called = 0;
        int listener2Called = 0;
        int listener3Called = 0;

        themeProvider.addListener(() => listener1Called++);
        themeProvider.addListener(() => listener2Called++);
        themeProvider.addListener(() => listener3Called++);

        themeProvider.setSeedColor(Colors.red);

        expect(listener1Called, equals(1));
        expect(listener2Called, equals(1));
        expect(listener3Called, equals(1));
      });

      test('should stop notifying removed listeners', () {
        int callCount = 0;
        void listener() => callCount++;

        themeProvider.addListener(listener);
        themeProvider.setSeedColor(Colors.blue);
        expect(callCount, equals(1));

        themeProvider.removeListener(listener);
        themeProvider.setSeedColor(Colors.red);
        expect(callCount, equals(1)); // Should not increment
      });

      test('should handle listener removal during notification', () {
        int callCount = 0;
        late VoidCallback listener;
        
        listener = () {
          callCount++;
          themeProvider.removeListener(listener);
        };

        themeProvider.addListener(listener);
        expect(() => themeProvider.setSeedColor(Colors.purple), returnsNormally);
        expect(callCount, equals(1));
      });
    });

    group('state consistency', () {
      test('should maintain consistent state after multiple operations', () {
        themeProvider.setSeedColor(Colors.indigo);
        themeProvider.setThemeMode(ThemeMode.dark);

        expect(themeProvider.seedColor, equals(Colors.indigo));
        expect(themeProvider.themeMode, equals(ThemeMode.dark));
        expect(themeProvider.lightTheme.colorScheme.brightness, equals(Brightness.light));
        expect(themeProvider.darkTheme.colorScheme.brightness, equals(Brightness.dark));
      });

      test('should preserve theme mode when seed color changes', () {
        themeProvider.setThemeMode(ThemeMode.light);
        themeProvider.setSeedColor(Colors.teal);

        expect(themeProvider.themeMode, equals(ThemeMode.light));
      });

      test('should preserve seed color when theme mode changes', () {
        themeProvider.setSeedColor(Colors.deepOrange);
        themeProvider.setThemeMode(ThemeMode.dark);

        expect(themeProvider.seedColor, equals(Colors.deepOrange));
      });
    });

    group('theme generation consistency', () {
      test('should generate same theme for same seed color', () {
        themeProvider.setSeedColor(Colors.cyan);
        final theme1 = themeProvider.lightTheme;
        final theme2 = themeProvider.lightTheme;

        expect(theme1.colorScheme.primary, equals(theme2.colorScheme.primary));
        expect(theme1.colorScheme.secondary, equals(theme2.colorScheme.secondary));
      });

      test('should generate different light and dark themes for same seed', () {
        themeProvider.setSeedColor(Colors.lime);
        final lightTheme = themeProvider.lightTheme;
        final darkTheme = themeProvider.darkTheme;

        expect(lightTheme.colorScheme.brightness, equals(Brightness.light));
        expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
        expect(lightTheme.colorScheme.surface, isNot(equals(darkTheme.colorScheme.surface)));
        expect(lightTheme.colorScheme.onSurface, isNot(equals(darkTheme.colorScheme.onSurface)));
      });
    });

    group('edge cases', () {
      test('should handle rapid consecutive calls', () {
        int notificationCount = 0;
        themeProvider.addListener(() => notificationCount++);

        for (int i = 0; i < 100; i++) {
          themeProvider.setSeedColor(Color(0xFF000000 + i));
        }

        expect(notificationCount, equals(100));
      });

      test('should handle alternating between two colors', () {
        final colors = [Colors.black, Colors.white];
        int notificationCount = 0;
        themeProvider.addListener(() => notificationCount++);

        for (int i = 0; i < 10; i++) {
          themeProvider.setSeedColor(colors[i % 2]);
        }

        expect(notificationCount, equals(10));
        expect(themeProvider.seedColor, equals(Colors.black));
      });

      test('should handle alternating between theme modes', () {
        final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
        int notificationCount = 0;
        themeProvider.addListener(() => notificationCount++);

        for (int i = 0; i < 9; i++) {
          themeProvider.setThemeMode(modes[i % 3]);
        }

        expect(notificationCount, equals(9));
        expect(themeProvider.themeMode, equals(ThemeMode.system));
      });
    });

    group('ColorScheme properties verification', () {
      test('should generate valid ColorScheme for light theme', () {
        themeProvider.setSeedColor(Colors.blue);
        final theme = themeProvider.lightTheme;
        final colorScheme = theme.colorScheme;

        expect(colorScheme.brightness, equals(Brightness.light));
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.onPrimary, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.onSecondary, isNotNull);
        expect(colorScheme.surface, isNotNull);
        expect(colorScheme.onSurface, isNotNull);
        expect(colorScheme.background, isNotNull);
        expect(colorScheme.onBackground, isNotNull);
      });

      test('should generate valid ColorScheme for dark theme', () {
        themeProvider.setSeedColor(Colors.red);
        final theme = themeProvider.darkTheme;
        final colorScheme = theme.colorScheme;

        expect(colorScheme.brightness, equals(Brightness.dark));
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.onPrimary, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.onSecondary, isNotNull);
        expect(colorScheme.surface, isNotNull);
        expect(colorScheme.onSurface, isNotNull);
        expect(colorScheme.background, isNotNull);
        expect(colorScheme.onBackground, isNotNull);
      });
    });

    group('extreme color values', () {
      test('should handle pure black seed color', () {
        expect(() => themeProvider.setSeedColor(Colors.black), returnsNormally);
        expect(themeProvider.lightTheme.colorScheme.brightness, equals(Brightness.light));
        expect(themeProvider.darkTheme.colorScheme.brightness, equals(Brightness.dark));
      });

      test('should handle pure white seed color', () {
        expect(() => themeProvider.setSeedColor(Colors.white), returnsNormally);
        expect(themeProvider.lightTheme.colorScheme.brightness, equals(Brightness.light));
        expect(themeProvider.darkTheme.colorScheme.brightness, equals(Brightness.dark));
      });

      test('should handle transparent seed color', () {
        expect(() => themeProvider.setSeedColor(Colors.transparent), returnsNormally);
        expect(themeProvider.lightTheme.colorScheme.brightness, equals(Brightness.light));
        expect(themeProvider.darkTheme.colorScheme.brightness, equals(Brightness.dark));
      });

      test('should handle very bright colors', () {
        final brightColors = [
          const Color(0xFFFFFFFF),
          const Color(0xFFFF0000),
          const Color(0xFF00FF00),
          const Color(0xFF0000FF),
        ];

        for (final color in brightColors) {
          expect(() => themeProvider.setSeedColor(color), returnsNormally);
          expect(themeProvider.seedColor, equals(color));
        }
      });

      test('should handle very dark colors', () {
        final darkColors = [
          const Color(0xFF000000),
          const Color(0xFF330000),
          const Color(0xFF003300),
          const Color(0xFF000033),
        ];

        for (final color in darkColors) {
          expect(() => themeProvider.setSeedColor(color), returnsNormally);
          expect(themeProvider.seedColor, equals(color));
        }
      });
    });

    group('memory and performance', () {
      test('should not leak listeners on repeated operations', () {
        // Add and remove listeners multiple times
        for (int i = 0; i < 10; i++) {
          void listener() {}
          themeProvider.addListener(listener);
          themeProvider.removeListener(listener);
        }

        // Should still work normally
        bool notified = false;
        themeProvider.addListener(() => notified = true);
        themeProvider.setSeedColor(Colors.pink);
        expect(notified, isTrue);
      });

      test('should handle many rapid color changes efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          themeProvider.setSeedColor(Color(0xFF000000 + (i % 0xFFFFFF)));
        }
        
        stopwatch.stop();
        // Verify operations complete in reasonable time (adjust as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });
  });
}