import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainleap/widgets/whiteboard_canvas.dart';

void main() {
  group('WhiteboardCanvas Widget Tests', () {
    late WhiteboardController controller;

    setUp(() {
      controller = WhiteboardController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should render without errors', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhiteboardCanvas(controller: controller),
          ),
        ),
      );

      // Assert
      expect(find.byType(WhiteboardCanvas), findsOneWidget);
    });

    testWidgets('should show clear button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhiteboardCanvas(controller: controller),
          ),
        ),
      );

      // Assert
      expect(find.text('Clear'), findsOneWidget);
      expect(find.byIcon(Icons.delete_sweep_outlined), findsOneWidget);
    });

    testWidgets('should clear points when clear button is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhiteboardCanvas(controller: controller),
          ),
        ),
      );

      // Add some points
      controller.addPoint(const Offset(10, 10));
      controller.addPoint(const Offset(20, 20));
      expect(controller.points.length, 2);

      // Act
      await tester.tap(find.text('Clear'));
      await tester.pump();

      // Assert
      expect(controller.points.length, 0);
    });

    test('WhiteboardController should add points', () {
      // Act
      controller.addPoint(const Offset(10, 10));
      controller.addPoint(const Offset(20, 20));
      controller.addPoint(const Offset(30, 30));

      // Assert
      expect(controller.points.length, 3);
      expect(controller.points[0], const Offset(10, 10));
      expect(controller.points[1], const Offset(20, 20));
      expect(controller.points[2], const Offset(30, 30));
    });

    test('WhiteboardController should clear all points', () {
      // Arrange
      controller.addPoint(const Offset(10, 10));
      controller.addPoint(const Offset(20, 20));
      expect(controller.points.length, 2);

      // Act
      controller.clear();

      // Assert
      expect(controller.points.length, 0);
    });

    test('WhiteboardController should serialize points', () {
      // Arrange
      controller.addPoint(const Offset(10.5, 20.5));
      controller.addPoint(const Offset(30.5, 40.5));

      // Act
      final serialized = controller.serialize();

      // Assert
      expect(serialized, contains('10.5'));
      expect(serialized, contains('20.5'));
      expect(serialized, contains('30.5'));
      expect(serialized, contains('40.5'));
    });

    test('WhiteboardController should notify listeners', () {
      // Arrange
      var notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      // Act
      controller.addPoint(const Offset(10, 10));
      controller.addPoint(const Offset(20, 20));
      controller.clear();

      // Assert
      expect(notificationCount, 3); // 2 adds + 1 clear
    });
  });
}

