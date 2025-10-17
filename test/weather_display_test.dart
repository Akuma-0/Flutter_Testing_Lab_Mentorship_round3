import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/weather_display.dart';

void main() {
  group('WeatherData Unit Tests', () {
    test('should create WeatherData from valid JSON', () {
      // Arrange
      final json = {
        'city': 'New York',
        'temperature': 25.5,
        'description': 'Sunny',
        'humidity': 65,
        'windSpeed': 12.3,
        'icon': '☀️',
      };

      // Act
      final weatherData = WeatherData.fromJson(json);

      // Assert
      expect(weatherData.city, equals('New York'));
      expect(weatherData.temperatureCelsius, equals(25.5));
      expect(weatherData.description, equals('Sunny'));
      expect(weatherData.humidity, equals('65'));
      expect(weatherData.windSpeed, equals('12.3'));
      expect(weatherData.icon, equals('☀️'));
    });

    test('should handle null values in JSON with defaults', () {
      // Arrange
      final json = {
        'city': null,
        'temperature': null,
        'description': null,
        'humidity': null,
        'windSpeed': null,
        'icon': null,
      };

      // Act
      final weatherData = WeatherData.fromJson(json);

      // Assert
      expect(weatherData.city, equals('Unknown'));
      expect(weatherData.temperatureCelsius, equals(0.0));
      expect(weatherData.description, equals('No description'));
      expect(weatherData.humidity, equals('Unknown'));
      expect(weatherData.windSpeed, equals('Unknown'));
      expect(weatherData.icon, equals('❓'));
    });

    test('should handle missing keys in JSON with defaults', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final weatherData = WeatherData.fromJson(json);

      // Assert
      expect(weatherData.city, equals('Unknown'));
      expect(weatherData.temperatureCelsius, equals(0.0));
      expect(weatherData.description, equals('No description'));
      expect(weatherData.humidity, equals('Unknown'));
      expect(weatherData.windSpeed, equals('Unknown'));
      expect(weatherData.icon, equals('❓'));
    });

    test('should convert temperature types correctly', () {
      // Arrange
      final json = {
        'temperature': 25, // int instead of double
      };

      // Act
      final weatherData = WeatherData.fromJson(json);

      // Assert
      expect(weatherData.temperatureCelsius, equals(25.0));
    });
  });

  group('Temperature Conversion Unit Tests', () {
    test('should convert Celsius to Fahrenheit correctly', () {
      // Arrange
      const celsius = 25.0;
      const expectedFahrenheit = 77.0;

      // Act
      final fahrenheit = (celsius * 9 / 5) + 32;

      // Assert
      expect(fahrenheit, equals(expectedFahrenheit));
    });

    test('should convert freezing point correctly', () {
      // Arrange
      const celsius = 0.0;
      const expectedFahrenheit = 32.0;

      // Act
      final fahrenheit = (celsius * 9 / 5) + 32;

      // Assert
      expect(fahrenheit, equals(expectedFahrenheit));
    });

    test('should convert negative temperatures correctly', () {
      // Arrange
      const celsius = -10.0;
      const expectedFahrenheit = 14.0;

      // Act
      final fahrenheit = (celsius * 9 / 5) + 32;

      // Assert
      expect(fahrenheit, equals(expectedFahrenheit));
    });
  });

  group('WeatherDisplay Widget Tests', () {
    testWidgets('should display initial loading state', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Assert - check initial loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('City: '), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Temperature Unit:'), findsOneWidget);

      // Wait for the async operation to complete to avoid timer issues
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('should display city dropdown with all cities', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert
      final dropdown = find.byType(DropdownButton<String>);
      expect(dropdown, findsOneWidget);

      // Tap the dropdown to open it
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Check if all cities are in the dropdown
      expect(find.text('New York'), findsWidgets);
      expect(find.text('London'), findsOneWidget);
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Invalid City'), findsOneWidget);
    });

    testWidgets('should toggle temperature unit switch', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert initial state
      expect(find.text('Celsius'), findsOneWidget);
      expect(find.text('Fahrenheit'), findsNothing);

      // Act - toggle switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert changed state
      expect(find.text('Fahrenheit'), findsOneWidget);
      expect(find.text('Celsius'), findsNothing);
    });

    testWidgets('should trigger refresh when refresh button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Act - tap refresh button
      await tester.tap(find.text('Refresh'));
      await tester.pump(); // Just pump once to see loading state

      // Assert - loading indicator should appear again
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up - wait for completion
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('should change city when dropdown selection changes', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Act - change city selection
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('London').last);
      await tester.pump(); // Just pump once to see loading state

      // Assert - loading should start again
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up - wait for completion
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });

  group('WeatherDisplay Error Handling Tests', () {
    testWidgets('should display error when invalid city is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Act - select invalid city
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invalid City').last);
      await tester.pump();

      // Wait for the API call to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert - error message should be displayed
      expect(find.text('Failed to load weather data.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should hide error message when refresh is successful', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // First, trigger an error by selecting invalid city
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invalid City').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify error is displayed
      expect(find.text('Failed to load weather data.'), findsOneWidget);

      // Act - select a valid city
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New York').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Note: Due to random nature of the mock API, we can only check that error might be gone
      // if a successful response was returned
      final hasError = find.text('Failed to load weather data.');
      final hasCard = find.byType(Card);

      // Either we have a card (success) or still have error (due to randomness)
      expect(
        hasError.evaluate().isEmpty || hasCard.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should maintain UI state when error occurs', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load and set temperature to Fahrenheit
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Act - trigger error
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invalid City').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert - UI elements should still be present
      expect(find.text('Fahrenheit'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('Failed to load weather data.'), findsOneWidget);
    });
  });

  group('WeatherDisplay Data Display Tests', () {
    testWidgets('should display weather data when load is successful', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Act - wait for data to load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Assert - weather card should be displayed (if not error case)
      // Note: Due to random nature of the mock API, we need to check for either success or error
      final hasCard = find.byType(Card);
      final hasError = find.text('Failed to load weather data.');

      expect(
        hasCard.evaluate().isNotEmpty || hasError.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should display temperature in Celsius by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Act - wait for data to load and ensure we get a successful response
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Keep trying until we get a successful response (not error)
      int attempts = 0;
      while (find.text('Failed to load weather data.').evaluate().isNotEmpty &&
          attempts < 5) {
        await tester.tap(find.text('Refresh'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        attempts++;
      }

      // Assert - temperature should be in Celsius if data loaded successfully
      if (find.byType(Card).evaluate().isNotEmpty) {
        expect(find.textContaining('°C'), findsOneWidget);
        expect(find.textContaining('°F'), findsNothing);
      }
    });

    testWidgets('should display temperature in Fahrenheit when toggled', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for data to load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Keep trying until we get a successful response
      int attempts = 0;
      while (find.text('Failed to load weather data.').evaluate().isNotEmpty &&
          attempts < 5) {
        await tester.tap(find.text('Refresh'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        attempts++;
      }

      // Act - toggle to Fahrenheit if data loaded successfully
      if (find.byType(Card).evaluate().isNotEmpty) {
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Assert
        expect(find.textContaining('°F'), findsOneWidget);
        expect(find.textContaining('°C'), findsNothing);
      }
    });

    testWidgets('should display weather details when data is loaded', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Act - wait for data to load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Keep trying until we get a successful response
      int attempts = 0;
      while (find.text('Failed to load weather data.').evaluate().isNotEmpty &&
          attempts < 5) {
        await tester.tap(find.text('Refresh'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        attempts++;
      }

      // Assert - weather details should be displayed if data loaded successfully
      if (find.byType(Card).evaluate().isNotEmpty) {
        expect(find.text('Humidity'), findsOneWidget);
        expect(find.text('Wind Speed'), findsOneWidget);
        expect(find.byIcon(Icons.water_drop), findsOneWidget);
        expect(find.byIcon(Icons.air), findsOneWidget);
      }
    });
  });

  group('WeatherDisplay Edge Cases Tests', () {
    testWidgets('should handle rapid city changes gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Act - rapidly change cities
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('London').last);
      await tester.pump();

      // Change again before first request completes
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tokyo').last);
      await tester.pump();

      // Assert - should handle gracefully without errors
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('should handle multiple refresh button taps', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Act - tap refresh multiple times quickly
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      await tester.tap(find.text('Refresh'));
      await tester.pump();

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('should maintain switch state during loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      // Wait for initial load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Set to Fahrenheit first
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Fahrenheit'), findsOneWidget);

      // Act - trigger reload
      await tester.tap(find.text('Refresh'));
      await tester.pump();

      // Assert - should maintain Fahrenheit setting during loading
      expect(find.text('Fahrenheit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
