// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brainleap/main.dart';

void main() {
  testWidgets('BrainLeapApp renders home tab by default', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BrainLeapApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Select Topic'), findsOneWidget);
    expect(find.text('Open Practice Whiteboard'), findsOneWidget);
  });
}
