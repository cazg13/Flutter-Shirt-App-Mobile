import 'package:flutter/material.dart';
import 'package:flutter_clothingapp/models/shoe.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final Shoe shoe;

  const CartItem({
    super.key,
    required this.shoe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: ListTile(
        leading: Image.network(
          shoe.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            );
           },
        ),
        title: Text(shoe.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '\$${shoe.price}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Size: ${shoe.selectedSize ?? 'N/A'}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
             const SizedBox(height: 8),
            // Nút +/- để tang giảm quantity
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    Provider.of<Cart>(context, listen: false).decreaseQuantity(shoe);
                  },
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                ),
                Text(
                  '${shoe.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    Provider.of<Cart>(context, listen: false).increaseQuantity(shoe);
                  },
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            Provider.of<Cart>(context, listen: false).removeItemfromCart(shoe);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${shoe.name} (Size: ${shoe.selectedSize ?? 'N/A'}) removed from cart'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}