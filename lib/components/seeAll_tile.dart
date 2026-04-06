import 'package:flutter/material.dart';
import 'package:flutter_clothingapp/models/shirt.dart';
import 'package:flutter_clothingapp/components/shirtInfo.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:provider/provider.dart';

class SeeAllTile extends StatelessWidget {
  final Shirt shirt;
  final void Function(Shirt)? onAddToCart;

  const SeeAllTile({
    super.key,
    required this.shirt,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
       GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShirtInfo(shirt: shirt),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh sản phẩm
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      shirt.imageUrl,
                      width: 200,
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
              ),
      
              // Thông tin sản phẩm
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sản phẩm
                    Text(
                      shirt.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
      
                   
                    
                    // Stock Status
                    Text(
                      shirt.stock > 3 ? 'Còn hàng' : 'Hết hàng',
                      style: TextStyle(
                        color: shirt.stock > 3 ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

      
                    // Giá + Button Add
                    
                  ],
                ),
              ),
                    Padding(
                      padding: const EdgeInsets.only(left:12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${shirt.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShirtInfo(shirt: shirt),
                                  ),
                                );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: const Icon(
                                Icons.info,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
       // Overlay blur khi hết hàng
      if (shirt.stock <= 3)
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Hết Hàng',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}