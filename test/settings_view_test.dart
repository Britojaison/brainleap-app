import 'package:brainleap/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SettingsView renders required menu items', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SettingsView())));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Share with your friends'), findsOneWidget);
  });

  testWidgets('SettingsView toggles notifications switch', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SettingsView())));

    final switchFinder = find.byKey(const ValueKey('settings_notification_toggle'));

    expect(tester.widget<Switch>(switchFinder).value, true);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(switchFinder).value, false);
  });
}

