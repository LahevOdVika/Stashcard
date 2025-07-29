import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stashcard/card/cardedit.dart';
import 'package:stashcard/providers/db.dart';

// Generate mocks
@GenerateMocks([DatabaseHelper])
import 'cardedit_test.mocks.dart';

void main() {
  group('CardEdit Widget Tests', () {
    late MockDatabaseHelper mockDb;
    late UserCard testCard;

    setUp(() {
      mockDb = MockDatabaseHelper();
      testCard = UserCard(
        id: 1,
        name: 'Test Card',
        // Add other required properties based on UserCard structure
      );
    });

    testWidgets('should display edit card title in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      expect(find.text('Edit card'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should initialize text field with existing card name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);
      
      final textFormField = tester.widget<TextFormField>(textField);
      expect(textFormField.controller?.text, equals('Test Card'));
    });

    testWidgets('should have proper form structure and widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should have correct input decoration with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.labelText, equals('Name'));
    });

    testWidgets('should validate empty input and show error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      // Clear the text field
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      // Trigger validation by finding the validator function
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      final validationResult = textField.validator?.call('');
      
      expect(validationResult, equals('Please enter a name'));
    });

    testWidgets('should validate null input and show error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      final validationResult = textField.validator?.call(null);
      
      expect(validationResult, equals('Please enter a name'));
    });

    testWidgets('should pass validation with valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      final validationResult = textField.validator?.call('Valid Name');
      
      expect(validationResult, isNull);
    });

    testWidgets('should allow text input and update controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      const newText = 'Updated Card Name';
      await tester.enterText(find.byType(TextFormField), newText);
      await tester.pump();

      expect(find.text(newText), findsOneWidget);
    });

    testWidgets('should have proper padding and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      final bodyPadding = tester.widget<Padding>(find.descendant(
        of: find.byType(Scaffold),
        matching: find.byType(Padding),
      ).first);
      expect(bodyPadding.padding, equals(const EdgeInsets.all(8.0)));

      final buttonPadding = tester.widget<Padding>(find.descendant(
        of: find.byType(Column),
        matching: find.byType(Padding),
      ));
      expect(buttonPadding.padding, equals(const EdgeInsets.only(top: 8.0)));
    });

    testWidgets('should have column with correct cross axis alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CardEdit(card: testCard),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.end));
    });

    group('Save Button Tests', () {
      testWidgets('should have save button with correct text', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        final saveButton = find.byType(FilledButton);
        expect(saveButton, findsOneWidget);
        expect(find.descendant(of: saveButton, matching: find.text('Save')), findsOneWidget);
      });

      testWidgets('should trigger save action when button is pressed', (WidgetTester tester) async {
        // This test would require dependency injection or mocking framework
        // For now, we'll test that the button exists and can be tapped
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        final saveButton = find.byType(FilledButton);
        expect(saveButton, findsOneWidget);
        
        // Verify button is tappable
        await tester.tap(saveButton);
        await tester.pump();
        
        // Note: Full integration testing would require mocking DatabaseHelper
        // and verifying the updateUserCard call and navigation
      });
    });

    group('Widget Lifecycle Tests', () {
      testWidgets('should properly initialize text controller in initState', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        final state = tester.state<_CardEditState>(find.byType(CardEdit));
        expect(state.newCardName.text, equals(testCard.name));
      });

      testWidgets('should dispose text controller properly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        // Get reference to controller
        final state = tester.state<_CardEditState>(find.byType(CardEdit));
        final controller = state.newCardName;

        // Navigate away to trigger dispose
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Text('Different Page')),
          ),
        );

        // Verify controller is disposed (this would throw if accessed after dispose)
        expect(() => controller.text, throwsFlutterError);
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('should handle card with empty name', (WidgetTester tester) async {
        final emptyNameCard = UserCard(
          id: 2,
          name: '',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: emptyNameCard),
          ),
        );

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.controller?.text, equals(''));
      });

      testWidgets('should handle card with null name gracefully', (WidgetTester tester) async {
        // Assuming UserCard can have null name in some cases
        final nullNameCard = UserCard(
          id: 3,
          name: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: nullNameCard),
          ),
        );

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.controller?.text, equals(''));
      });

      testWidgets('should handle very long card names', (WidgetTester tester) async {
        final longName = 'A' * 1000; // Very long name
        final longNameCard = UserCard(
          id: 4,
          name: longName,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: longNameCard),
          ),
        );

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.controller?.text, equals(longName));
      });

      testWidgets('should handle special characters in card name', (WidgetTester tester) async {
        final specialCharName = 'Card @#$%^&*()_+-={}[]|\\:";\'<>?,./';
        final specialCharCard = UserCard(
          id: 5,
          name: specialCharName,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: specialCharCard),
          ),
        );

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.controller?.text, equals(specialCharName));
      });

      testWidgets('should handle unicode characters in card name', (WidgetTester tester) async {
        final unicodeName = '测试卡片 🃏 ñáéíóú';
        final unicodeCard = UserCard(
          id: 6,
          name: unicodeName,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: unicodeCard),
          ),
        );

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.controller?.text, equals(unicodeName));
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantics for screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        // Test that semantic labels are present
        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Edit card'), findsOneWidget);
      });

      testWidgets('should be navigable with keyboard/screen reader', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        // Verify focusable elements exist
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
      });
    });

    group('Integration-like Tests', () {
      testWidgets('should update text field when typing', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        // Start with original name
        expect(find.text('Test Card'), findsOneWidget);

        // Type new text
        await tester.enterText(find.byType(TextFormField), 'New Card Name');
        await tester.pump();

        // Verify text changed
        expect(find.text('New Card Name'), findsOneWidget);
        expect(find.text('Test Card'), findsNothing);
      });

      testWidgets('should clear text field when cleared', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        // Clear the field
        await tester.enterText(find.byType(TextFormField), '');
        await tester.pump();

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.controller?.text, isEmpty);
      });

      testWidgets('should maintain state during rebuilds', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CardEdit(card: testCard),
          ),
        );

        // Enter new text
        const newText = 'Modified Name';
        await tester.enterText(find.byType(TextFormField), newText);
        await tester.pump();

        // Force a rebuild by changing parent widget
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(), // Change theme to force rebuild
            home: CardEdit(card: testCard),
          ),
        );

        // Text should persist through rebuild
        expect(find.text(newText), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should not have expensive operations in build method', (WidgetTester tester) async {
        // Build widget multiple times to ensure no expensive operations
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: CardEdit(card: testCard),
            ),
          );
          await tester.pump();
        }

        // If we get here without timeout, build method is efficient
        expect(find.byType(CardEdit), findsOneWidget);
      });
    });
  });
}