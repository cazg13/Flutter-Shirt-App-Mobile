import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/bloc/shoe_bloc.dart';
import 'package:flutter_clothingapp/bloc/shoe_state.dart';
import 'package:flutter_clothingapp/models/shoe.dart';
import 'package:flutter_clothingapp/components/seeAll_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// BẰNG:
class SeeAllPage extends StatefulWidget {
  const SeeAllPage({super.key});

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  // Thêm các biến ở đây
  String _sortOption = 'Tất cả';
  Map<String, int> _salesCount = {};
  bool _isLoadingSales = true;

  @override
  void initState() {
    super.initState();
    _loadSalesCount(); // Tải lượt bán khi page khởi động
  }

  // Tải số lượng bán từ Firestore
  Future<void> _loadSalesCount() async {
    try {
      Map<String, int> salesCount = {};
      
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      for (var orderDoc in ordersSnapshot.docs) {
        final items = orderDoc['items'] as List?;
        if (items != null) {
          for (var item in items) {
            final productCode = item['productCode'] ?? '';
            final quantity = (item['quantity'] as int?) ?? 1;
            
            if (productCode.isNotEmpty) {
              salesCount[productCode] = (salesCount[productCode] ?? 0) + quantity;
            }
          }
        }
      }

      setState(() {
        _salesCount = salesCount;
        _isLoadingSales = false;
      });
    } catch (e) {
      print('Error loading sales count: $e');
      setState(() {
        _isLoadingSales = false;
      });
    }
  }

  // Hàm sắp xếp sản phẩm
  List<Shoe> _sortedShoes(List<Shoe> shoes) {
    List<Shoe> sorted = List.from(shoes); // Tạo bản sao

    switch (_sortOption) {
      case 'Thấp đến cao':
        sorted.sort((a, b) => 
          double.parse(a.price).compareTo(double.parse(b.price))
        );
        break;

      case 'Cao đến thấp':
        sorted.sort((a, b) => 
          double.parse(b.price).compareTo(double.parse(a.price))
        );
        break;

      case 'Bán chạy':
        sorted.sort((a, b) {
          int aSales = _salesCount[a.id] ?? 0;
          int bSales = _salesCount[b.id] ?? 0;
          return bSales.compareTo(aSales); // Giảm dần
        });
        break;

      case 'Tất cả':
      default:
        // Giữ nguyên thứ tự
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả sản phẩm'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Tất cả',
                child: Row(
                  children: [
                    Icon(Icons.apps, size: 18),
                    SizedBox(width: 12),
                    Text('Tất cả'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Thấp đến cao',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 18),
                    SizedBox(width: 12),
                    Text('Thấp đến cao'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Cao đến thấp',
                child: Row(
                  children: [
                    Icon(Icons.trending_down, size: 18),
                    SizedBox(width: 12),
                    Text('Cao đến thấp'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Bán chạy',
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 18),
                    SizedBox(width: 12),
                    Text('Bán chạy'),
                  ],
                ),
              ),
            ],
            tooltip: 'Sắp xếp sản phẩm',
            padding: const EdgeInsets.all(8),
            child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.sort, color: Color.fromARGB(255, 0, 0, 0), size: 22),
                ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ShoeBloc, ShoeState>(
        builder: (context, state) {
          if (state is ShoeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ShoeLoaded) {
            // Lấy danh sách đã sắp xếp
            List<Shoe> displayedShoes = _sortedShoes(state.shoes);

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(15),
              itemCount: displayedShoes.length,
              itemBuilder: (context, index) {
                Shoe shoe = displayedShoes[index];
                return SeeAllTile(
                  shoe: shoe,
                  onAddToCart: (shoe) {
                    Provider.of<Cart>(context, listen: false)
                        .addItemToCart(shoe);
                  },
                );
              },
            );
          }

          if (state is ShoeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: Text('No products'));
        },
      ),
    );
  }
}