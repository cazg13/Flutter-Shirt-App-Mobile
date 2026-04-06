import 'package:flutter/material.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:flutter_clothingapp/models/shirt.dart';
import 'package:provider/provider.dart';

class ShirtInfo extends StatefulWidget {
  final Shirt shirt;

  const ShirtInfo({
    super.key,
    required this.shirt,
  });

  @override
  State<ShirtInfo> createState() => _ShirtInfoState();
}

class _ShirtInfoState extends State<ShirtInfo> {
  String? selectedSize;
  void addShirtToCart(BuildContext context) {
            if (selectedSize == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng chọn size'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              if (widget.shirt.stock <= 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sản phẩm đã hết hàng'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              widget.shirt.selectedSize = selectedSize;
              Provider.of<Cart>(context, listen: false).addItemToCart(widget.shirt);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.shirt.name} (Size $selectedSize) added to cart'),
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() {
                selectedSize = null;
              });
       }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shirt.name),
      ),
      body: Container(
        margin: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Shirt picture
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.shirt.imageUrl,
                    width: 400,
                    height: 700,
                    
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 20),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Text(
                widget.shirt.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 10),

            // Available sizes
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Sizes:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                      spacing: 8.0,
              runSpacing: 8.0,
              children: widget.shirt.sizes
                  .map((size) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSize = size;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: selectedSize == size
                                ? Colors.black
                                : Colors.grey[200],
                            border: Border.all(
                              color: selectedSize == size
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              size,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: selectedSize == size
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Price + Add Button
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shirt Name
                      Text(
                        widget.shirt.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Price
                      Text(
                        '\$${widget.shirt.price}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Stock
                      Text(
                        widget.shirt.stock > 3 ? 'Còn hàng' : 'Hết hàng',
                        style: TextStyle(
                          color: widget.shirt.stock > 3 ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Add Button
                  GestureDetector(
                    onTap: widget.shirt.stock > 3 ? () => addShirtToCart(context) : null,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.shirt.stock > 3 ? Colors.black : Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}