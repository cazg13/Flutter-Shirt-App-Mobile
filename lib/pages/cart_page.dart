import 'package:flutter/material.dart';
import 'package:flutter_clothingapp/components/cart_item.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_clothingapp/pages/order_checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, cart, child) => Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              'Giỏ hàng của tôi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Cart Items List
          Expanded(
            child: ListView.builder(
              itemCount: cart.getUserCart().length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: CartItem(
                    shoe: cart.getUserCart()[index],
                  ),
                );
              },
            ),
          ),

          // Total and Checkout
          if (cart.getUserCart().isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    // Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng:',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_calculateTotal(cart).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Checkout Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderCheckoutPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Thanh toán',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Empty Cart Message
          if (cart.getUserCart().isEmpty)
            const Expanded(
              child: Center(
                child: Text('Giỏ hàng của bạn đang trống.'),
              ),
            ),
        ],
      ),
    );
  }

  double _calculateTotal(Cart cart) {
    double total = 0;
    for (var shoe in cart.getUserCart()) {
      total += double.parse(shoe.price)*shoe.quantity;
    }
    return total;
  }
}