import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_clothingapp/pages/Dashboard/full_orders_management_page.dart';
import 'package:flutter_clothingapp/models/order.dart';

class SearchOrderPage extends StatefulWidget {
  const SearchOrderPage({super.key});

  @override
  State<SearchOrderPage> createState() => _SearchOrderPageState();
}

class _SearchOrderPageState extends State<SearchOrderPage> {
  final TextEditingController _searchController = TextEditingController();

  List<QueryDocumentSnapshot> allOrders = [];
  List<QueryDocumentSnapshot> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    setState(() {
      allOrders = snapshot.docs;
      isLoading = false;
    });
  }

  /// 🔍 SEARCH theo 6 ký tự cuối ID
  void searchOrder(String value) {
    if (value.isEmpty) {
      setState(() => results = []);
      return;
    }

    final filtered = allOrders.where((doc) {
      return doc.id.toLowerCase().endsWith(value.toLowerCase());
    }).toList();

    setState(() => results = filtered);
  }

  /// 🔢 Lấy 6 ký tự cuối ID
  String getOrderCode(String id) {
    if (id.length < 6) return id;
    return id.substring(id.length - 6).toUpperCase();
  }

  /// 🎨 Màu status
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 📝 Text status
  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipping':
        return 'Đang giao';
      case 'completed':
        return 'Hoàn tất';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Order")),
      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: searchOrder,
              decoration: const InputDecoration(
                hintText: "Nhập ID đơn hàng...",
                border: InputBorder.none,
              ),
            ),
          ),

          /// ⏳ LOADING
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),

          /// 📦 RESULT
          if (!isLoading && results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final doc = results[index];

                  /// 🔥 TẠO ORDER TỪ FIRESTORE
                    final order = ShopOrder.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullOrdersManagementPage(order: order),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            /// LEFT
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đơn #${getOrderCode(doc.id)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} sản phẩm',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// MIDDLE
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${order.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.createdAt
                                      .toString()
                                      .split(' ')[0],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 10),

                            /// RIGHT (STATUS)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: getStatusColor(order.status)
                                    .withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                              child: Text(
                                getStatusText(order.status),
                                style: TextStyle(
                                  color:
                                      getStatusColor(order.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          /// ❌ NOT FOUND
          if (!isLoading &&
              results.isEmpty &&
              _searchController.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Không tìm thấy order"),
            ),
        ],
      ),
    );
  }
}
