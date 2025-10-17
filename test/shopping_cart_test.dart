import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/shopping_cart.dart';

void main() {
  group('CartItem unit tests', () {
    test('should create CartItem with correct properties', () {
      final cartItem = CartItem(
        id: '1',
        name: 'Test Item',
        price: 10.99,
        quantity: 2,
        discount: 0.1,
      );

      expect(cartItem.id, '1');
      expect(cartItem.name, 'Test Item');
      expect(cartItem.price, 10.99);
      expect(cartItem.quantity, 2);
      expect(cartItem.discount, 0.1);
    });

    test('should create CartItem with default values', () {
      final cartItem = CartItem(id: '1', name: 'Test Item', price: 10.99);

      expect(cartItem.quantity, 1);
      expect(cartItem.discount, 0.0);
    });
  });

  group('ShoppingCart widget tests', () {
    late ShoppingCart shoppingCart;

    setUp(() {
      shoppingCart = const ShoppingCart();
    });

    testWidgets('should render empty cart initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
      expect(find.text('Subtotal: \$0.00'), findsOneWidget);
      expect(find.text('Total Discount: \$0.00'), findsOneWidget);
      expect(find.text('Total Amount: \$0.00'), findsOneWidget);
    });

    testWidgets('should add items to cart', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Cart is empty'), findsNothing);
      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Total Items: 1'), findsOneWidget);
      expect(find.text('Subtotal: \$999.99'), findsOneWidget);
      expect(find.text('Total Discount: \$100.00'), findsOneWidget);
      expect(find.text('Total Amount: \$899.99'), findsOneWidget);
    });

    testWidgets('should increase quantity when adding same item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone twice
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add iPhone Again'));
      await tester.pump();

      expect(find.text('Total Items: 2'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Quantity display
      expect(find.text('Subtotal: \$1999.98'), findsOneWidget);
      expect(
        find.text('Total Discount: \$200.00'),
        findsOneWidget,
      ); // 2 * 999.99 * 0.1 = 199.998 -> 200.00
      expect(find.text('Total Amount: \$1799.98'), findsOneWidget);
    });

    testWidgets('should add multiple different items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone and Galaxy
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();

      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('Samsung Galaxy'), findsOneWidget);
      expect(find.text('Total Items: 2'), findsOneWidget);
    });

    testWidgets('should update item quantity using + button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      // Increase quantity
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Total Items: 2'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Quantity display
    });

    testWidgets('should update item quantity using - button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone twice to have quantity 2
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add iPhone Again'));
      await tester.pump();

      // Decrease quantity
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('Total Items: 1'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Quantity display
    });

    testWidgets('should remove item when quantity becomes 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      // Decrease quantity to 0
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
    });

    testWidgets('should remove item using delete button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      // Remove item using delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
    });

    testWidgets('should clear entire cart', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: shoppingCart)),
        ),
      );

      // Add multiple items
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();
      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      // Clear cart
      await tester.tap(find.text('Clear Cart'));
      await tester.pump();

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
      expect(find.text('Subtotal: \$0.00'), findsOneWidget);
      expect(find.text('Total Discount: \$0.00'), findsOneWidget);
      expect(find.text('Total Amount: \$0.00'), findsOneWidget);
    });

    testWidgets('should calculate correct totals with discounts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone (10% discount) and iPad (no discount)
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();
      await tester.tap(find.text('Add iPad'));
      await tester.pump();

      // Subtotal: 999.99 + 1099.99 = 2099.98
      // Total Discount: 999.99 * 0.1 + 1099.99 * 0 = 100.00
      // Total Amount: 2099.98 - 100.00 = 1999.98
      expect(find.text('Subtotal: \$2099.98'), findsOneWidget);
      expect(find.text('Total Discount: \$100.00'), findsOneWidget);
      expect(find.text('Total Amount: \$1999.98'), findsOneWidget);
    });

    testWidgets('should display discount information for discounted items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone with discount
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      expect(find.text('Discount: 10%'), findsOneWidget);
    });

    testWidgets(
      'should not display item discount percentage for non-discounted items',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: shoppingCart)),
        );

        // Add iPad without discount
        await tester.tap(find.text('Add iPad'));
        await tester.pump();

        // Should find the item but no discount percentage for it
        expect(find.text('iPad Pro'), findsOneWidget);
        expect(find.text('Price: \$1099.99 each'), findsOneWidget);
        // The discount percentage should not be displayed for items with 0% discount
        expect(find.text('Discount: 0%'), findsNothing);

        // But total discount should still show $0.00 in the cart summary
        expect(find.text('Total Discount: \$0.00'), findsOneWidget);
      },
    );

    testWidgets('should display correct item totals with discounts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone with 10% discount
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      // Item total should be price * quantity - discount = 999.99 * 1 - (999.99 * 0.1) = 899.99
      expect(find.text('Item Total: \$899.99'), findsOneWidget);
    });

    testWidgets('should handle multiple quantity updates correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add iPhone
      await tester.tap(find.text('Add iPhone'));
      await tester.pump();

      // Increase quantity multiple times
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Total Items: 3'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Decrease quantity
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('Total Items: 2'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets(
      'should maintain correct totals after removing items from mixed cart',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: shoppingCart)),
          ),
        );

        // Add multiple items
        await tester.tap(find.text('Add iPhone')); // 999.99 with 10% discount
        await tester.pump();
        await tester.tap(find.text('Add Galaxy')); // 899.99 with 15% discount
        await tester.pump();
        await tester.tap(find.text('Add iPad')); // 1099.99 with no discount
        await tester.pump();

        // Verify initial totals
        expect(find.text('Total Items: 3'), findsOneWidget);

        // Remove Galaxy (middle item)
        final deleteButtons = find.byIcon(Icons.delete);
        await tester.tap(deleteButtons.at(1)); // Second delete button (Galaxy)
        await tester.pump();

        // Should now have iPhone and iPad only
        expect(find.text('Total Items: 2'), findsOneWidget);
        expect(find.text('Apple iPhone'), findsOneWidget);
        expect(find.text('iPad Pro'), findsOneWidget);
        expect(find.text('Samsung Galaxy'), findsNothing);

        // Verify recalculated totals (iPhone + iPad)
        expect(find.text('Subtotal: \$2099.98'), findsOneWidget);
        expect(
          find.text('Total Discount: \$100.00'),
          findsOneWidget,
        ); // Only iPhone discount
        expect(find.text('Total Amount: \$1999.98'), findsOneWidget);
      },
    );

    testWidgets('should handle edge case of reducing quantity to zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: shoppingCart)));

      // Add Galaxy and increase quantity to 3
      await tester.tap(find.text('Add Galaxy'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Total Items: 3'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Reduce quantity to zero by clicking minus 3 times
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Cart should be empty
      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Total Items: 0'), findsOneWidget);
      expect(find.text('Samsung Galaxy'), findsNothing);
    });
  });
}
