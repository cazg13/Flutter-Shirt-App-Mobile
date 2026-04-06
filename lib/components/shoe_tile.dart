import 'package:flutter/material.dart';
import 'package:flutter_clothingapp/components/shoeInfo.dart';
import 'package:flutter_clothingapp/models/shoe.dart';

// CẤU HÌNH CHO TỪNG THẺ SẢN PHẨM ở SHOP PAGE GIÀY, BAO GỒM HÌNH ẢNH, TÊN, GIÁ VÀ BUTTON ADD

class ShoeTile extends StatefulWidget {
  final Shoe shoe;
  final void Function(Shoe)? onTap;
  
  ShoeTile({
    super.key,
    required this.shoe,
    required this.onTap,
  });

  @override
  State<ShoeTile> createState() => _ShoeTileState();
}

class _ShoeTileState extends State<ShoeTile> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 25),
          width: 280,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Shoe picture
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.shoe.imageUrl,
                    width: 200,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
              // Description
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                child: Text(
                  widget.shoe.description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              // Price + Add Button
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shoe Name
                        Text(
                          widget.shoe.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Price
                        Text(
                          '\$${widget.shoe.price}',
                          style: TextStyle(
                            color: Colors.grey[1200],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.shoe.stock > 3 ? 'Còn hàng' : 'Hết hàng',
                          style: TextStyle(
                            color: widget.shoe.stock > 3 ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Info Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShoeInfo(shoe: widget.shoe),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Icon(
                          Icons.info,
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
        // Hết hàng overlay
      if (widget.shoe.stock <= 3)
        Container(
          margin: const EdgeInsets.only(left: 25),
          width: 280,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Hết Hàng',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}