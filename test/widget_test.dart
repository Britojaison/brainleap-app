// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brainleap/main.dart';

void main() {
  testWidgets('BrainLeapApp navigation updates visible page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BrainLeapApp());

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Home'),
      ),
      findsOneWidget,
    );
    expect(find.text('AI Hint'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    expect(find.text('History timeline will appear here.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings_logout_button')), findsOneWidget);
  });
}
