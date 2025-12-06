import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelmate/screens/flights_screen.dart';
import 'package:travelmate/models/airport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlightsScreen Widget Tests', () {
    // Test for input fields and search button properly rendered
    testWidgets('Renders all input fields and search button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FlightsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // check UI fields
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Round-trip'), findsOneWidget);
      expect(find.text('One-way'), findsOneWidget);
      expect(find.text('Passengers'), findsOneWidget);
      expect(find.text('Class'), findsOneWidget);
      expect(find.text('Search Flights'), findsOneWidget);
    });

    // Test if there's error validation messages
    testWidgets('Shows validation error if origin is not selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FlightsScreen()),
      );
      await tester.pumpAndSettle();

      // tap search button
      await tester.tap(find.text('Search Flights'));
      await tester.pumpAndSettle();

      // validation error message should be shown
      expect(find.text('From is required'), findsOneWidget);
    });
    
    // 
    testWidgets('FlightsScreen displays form fields and button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FlightsScreen()));
      await tester.pumpAndSettle();

      // test if buttons and fields have a widget
      expect(find.text('Round-trip'), findsOneWidget);
      expect(find.text('One-way'), findsOneWidget);
      expect(find.text('Departure'), findsOneWidget);
      expect(find.text('Return'), findsOneWidget);
      expect(find.text('Passengers'), findsOneWidget);
      expect(find.text('Class'), findsOneWidget);
      expect(find.text('Search Flights'), findsOneWidget);

    });
  });
}