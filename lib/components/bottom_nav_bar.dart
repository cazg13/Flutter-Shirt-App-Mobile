import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:flutter_clothingapp/components/red_dots.dart';

class BottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;
  final int selectedIndex;
  BottomNavBar({super.key, required this.onTabChange,required this.selectedIndex,});

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: GNav(
            color: Colors.grey[400],
            activeColor: Colors.grey.shade700,
            tabActiveBorder: Border.all(color: Colors.white),
            tabBackgroundColor: Colors.grey.shade100,
            mainAxisAlignment: MainAxisAlignment.center,
            tabBorderRadius: 16,
            onTabChange: (value) => onTabChange!(value),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Mua hàng',
              ),
              // Custom nút Cart với red dot
              GButton(
                icon: Icons.shopping_cart,
                text: 'Giỏ hàng',
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_cart,color:selectedIndex == 1 
                          ? Colors.grey.shade700 
                          : Colors.grey[400],),
                    if (cart.getUserCart().isNotEmpty)
                      // Sử dụng Positioned hợp lệ trong Stack, nhưng phải đảm bảo Stack có kích thước xác định
                      Positioned(
                        right: -15,
                        top: -15,
                        child: RedDot(),
                      ),
                  ],
                ),
              ),
              GButton(
                icon: Icons.info,
                text: 'Giới thiệu',
              ),
            ],
          ),
        );
      },
    );
  }
}