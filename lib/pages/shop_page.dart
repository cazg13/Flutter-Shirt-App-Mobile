import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/bloc/shoe_bloc.dart';
import 'package:flutter_clothingapp/bloc/shoe_event.dart';
import 'package:flutter_clothingapp/bloc/shoe_state.dart';
import 'package:flutter_clothingapp/components/shoe_tile.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:flutter_clothingapp/models/shoe.dart';
import 'package:flutter_clothingapp/components/shoeInfo.dart';
import 'package:provider/provider.dart';
import 'package:flutter_clothingapp/pages/seeAll_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<ShoeState> _shoeSubscription;

  void addShoeToCart(Shoe shoe) {
    Provider.of<Cart>(context, listen: false).addItemToCart(shoe);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${shoe.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

 @override
void initState() {
  super.initState();
  
  // Lắng nghe ShoeBloc để load shoes cho search
  _shoeSubscription = context.read<ShoeBloc>().stream.listen((state) {
    if (state is ShoeLoaded) {
      Provider.of<Cart>(context, listen: false).setAllShoes(state.shoes);
    }
  });
}
    // Lấy 3 sản phẩm bán chạy nhất trong năm
    Future<List<Shoe>> getTopSellingShoes() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month - 12, 1);
      final firstDayOfNextMonth = now.month == 12
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month, 1);

      print('🔍 DEBUG: Querying orders from $firstDayOfMonth to $firstDayOfNextMonth');

      // Lấy tất cả orders trong năm
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .where('createdAt',
              isLessThan: Timestamp.fromDate(firstDayOfNextMonth))
          .get();

      print('📦 Found ${ordersSnapshot.docs.length} orders');

      // Đếm lượt bán theo productDocId
      Map<String, int> salesCount = {};
      for (var orderDoc in ordersSnapshot.docs) {
        final items = orderDoc['items'] as List?;
        print('🛒 Order: items = $items');

        if (items != null) {
          for (var item in items) {
            print('📄 Item: $item');

            final productDocId = item['productCode'] ?? '';
            final quantity = (item['quantity'] as int?) ?? 1;

            print('💾 ProductDocId: $productDocId, Quantity: $quantity');

            if (productDocId.isNotEmpty) {
              salesCount[productDocId] = (salesCount[productDocId] ?? 0) + quantity;
            }
          }
        }
      }

      print('📊 SalesCount: $salesCount');

      // Sắp xếp theo số lượng bán (giảm dần)
      final sortedProducts = salesCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

      print('🏆 Sorted products: $sortedProducts');

      // Lấy 3 top
      final topProductIds = sortedProducts
          .take(3)
          .map((e) => e.key)
          .toList();

      print('🥇 Top 3 IDs: $topProductIds');

      if (topProductIds.isEmpty) {
        print('⚠️ No top products found!');
        return [];
      }

      // Query những shoes này từ Firestore
      final shoesSnapshot = await FirebaseFirestore.instance
          .collection('Shoe')
          .where('id', whereIn: topProductIds)
          .get();

      print('👟 Found ${shoesSnapshot.docs.length} shoes');

      final topShoes = shoesSnapshot.docs
          .map((doc) => Shoe.fromFirebase(doc.data(), doc.id))
          .toList();

      print('✅ Final topShoes: ${topShoes.map((s) => s.name).toList()}');

      return topShoes;
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoeBloc = context.read<ShoeBloc>();

    return Consumer<Cart>(
      builder: (context, cart, child) => Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      cart.searchShoe(value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm giày...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),

          // Search results
          if (cart.searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                maxHeight: 300,  // ← Giới hạn chiều cao
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                  )
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: cart.searchResults.length,
                itemBuilder: (context, index) {
                  Shoe shoe = cart.searchResults[index];
                  return ListTile(
                    leading: Image.network(
                     shoe.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 20),
                        );
                      },
                    ),
                    title: Text(shoe.name),
                    subtitle: Text('\$${shoe.price}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoeInfo(shoe: shoe),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          // Message
          if (cart.searchResults.isEmpty && _searchController.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Text(
                'Hãy tìm kiếm sản phẩm bạn muốn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),

          // Hot Picks section
          
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                  Text(
                    'Hot Picks 🔥',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SeeAllPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Tất cả',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 99, 122, 141),
                      ),
                    ),
                  )
                ],
              ),
            ),

          const SizedBox(height: 10),

          // Hot Picks - Top 3 selling shoes
          Expanded(
            child: FutureBuilder<List<Shoe>>(
              future: getTopSellingShoes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final topShoes = snapshot.data ?? [];

                if (topShoes.isEmpty) {
                  return const Center(
                    child: Text('No data available'),
                  );
                }

                

                return ListView.builder(
                  itemCount: topShoes.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    Shoe shoe = topShoes[index];
                    return ShoeTile(
                      shoe: shoe,
                      onTap: (shoe) => addShoeToCart(shoe),
                    );
                  },
                );
              },
            ),
          ),

          if (cart.searchResults.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
              child: Divider(
                color: Colors.grey[300],
              ),
            ),
        ],
      ),
    );
  }

@override
void dispose() {
  _searchController.dispose();
  _shoeSubscription.cancel();
  super.dispose();
}
}