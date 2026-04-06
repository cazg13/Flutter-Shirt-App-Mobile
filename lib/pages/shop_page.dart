import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/bloc/shirt_bloc.dart';
import 'package:flutter_clothingapp/bloc/shirt_event.dart';
import 'package:flutter_clothingapp/bloc/shirt_state.dart';
import 'package:flutter_clothingapp/components/shirt_tile.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:flutter_clothingapp/models/shirt.dart';
import 'package:flutter_clothingapp/components/shirtInfo.dart';
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
  late StreamSubscription<ShirtState> _shirtSubscription;

  void addShirtToCart(Shirt shirt) {
    Provider.of<Cart>(context, listen: false).addItemToCart(shirt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${shirt.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

 @override
void initState() {
  super.initState();
  
  // Lắng nghe ShirtBloc để load shirts cho search
  _shirtSubscription = context.read<ShirtBloc>().stream.listen((state) {
    if (state is ShirtLoaded) {
      Provider.of<Cart>(context, listen: false).setAllShirts(state.shirts);
    }
  });
}
    // Lấy 3 sản phẩm bán chạy nhất trong năm
    Future<List<Shirt>> getTopSellingShirts() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month - 12, 1);
      final firstDayOfNextMonth = now.month == 12
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month,now.day, 23);

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

      // Query những shirts này từ Firestore
      final shirtsSnapshot = await FirebaseFirestore.instance
          .collection('Shirt')
          .where('id', whereIn: topProductIds)
          .get();

      print('👟 Found ${shirtsSnapshot.docs.length} shirts');

      final topShirts = shirtsSnapshot.docs
          .map((doc) => Shirt.fromFirebase(doc.data(), doc.id))
          .toList();

      print('✅ Final topShirts: ${topShirts.map((s) => s.name).toList()}');

      return topShirts;
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final shirtBloc = context.read<ShirtBloc>();

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
                      cart.searchShirt(value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm áo...',
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
                  Shirt shirt = cart.searchResults[index];
                  return ListTile(
                    leading: Image.network(
                     shirt.imageUrl,
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
                    title: Text(shirt.name),
                    subtitle: Text('\$${shirt.price}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShirtInfo(shirt: shirt),
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

          // Hot Picks - Top 3 selling shirts
          Expanded(
            child: FutureBuilder<List<Shirt>>(
              future: getTopSellingShirts(),
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

                final topShirts = snapshot.data ?? [];

                if (topShirts.isEmpty) {
                  return const Center(
                    child: Text('No data available'),
                  );
                }

                

                return ListView.builder(
                  itemCount: topShirts.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    Shirt shirt = topShirts[index];
                    return ShirtTile(
                      shirt: shirt,
                      onTap: (shirt) => addShirtToCart(shirt),
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
  _shirtSubscription.cancel();
  super.dispose();
}
}