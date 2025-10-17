import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/user_registration_form.dart';

void main() {
  group('validation logic test', () {
    final email = 'test@example.com';
    final invalidEmail = 'testexample.com';
    final password = 'Password123!';
    final invalidPassword = 'pass';

    test('valid email test', () {
      bool _isEmailValid = isEmailValid(email);
      expect(_isEmailValid, true);
    });
    test('invalid email test', () {
      bool _isInvalidEmailValid = isEmailValid(invalidEmail);
      expect(_isInvalidEmailValid, false);
    });
    test('valid password test', () {
      bool _isPasswordValid = isPasswordValid(password);
      expect(_isPasswordValid, true);
    });
    test('invalid password test', () {
      bool _isInvalidPasswordValid = isPasswordValid(invalidPassword);
      expect(_isInvalidPasswordValid, false);
    });
  });

  testWidgets('UserRegistrationForm test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
    );
    // Find the email input field and enter text
    await tester.enterText(
      find.byKey(const ValueKey('email_field')),
      'test@example.com',
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Please enter a password'), findsOneWidget);
    // Find the password input field and enter text
    await tester.enterText(
      find.byKey(const ValueKey('password_field')),
      'Password123!',
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Please confirm your password'), findsOneWidget);
    // Find the confirm password input field and enter text
    await tester.enterText(
      find.byKey(const ValueKey('confirm_password_field')),
      'Password123!',
    );
    // Find the name input field and enter text
    await tester.enterText(
      find.byKey(const ValueKey('name_field')),
      'Test User',
    );
    // Tap the submit button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(seconds: 2)); // Start the async operation

    // Expect a success message after submission
    expect(find.text('Registration successful!'), findsOneWidget);
  });
}
