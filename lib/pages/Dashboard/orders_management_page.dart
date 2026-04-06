import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_clothingapp/models/order.dart';
import 'package:flutter_clothingapp/pages/Dashboard/full_orders_management_page.dart';

class OrdersManagementPage extends StatefulWidget {
  const OrdersManagementPage({super.key});

  @override
  State<OrdersManagementPage> createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends State<OrdersManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method lấy danh sách đơn hàng theo status
  Future<List<ShopOrder>> getOrdersByStatus(String status, int month, int year) async {
        try {
        // Tính ngày đầu tháng và đầu tháng tiếp theo
        final firstDayOfMonth = DateTime(year, month, 1);
        final firstDayOfNextMonth = month == 12 
            ? DateTime(year + 1, 1, 1)
            : DateTime(year, month + 1, 1);

        final querySnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: status)
            .where('createdAt', 
                isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
            .where('createdAt', 
                isLessThan: Timestamp.fromDate(firstDayOfNextMonth))
            .orderBy('createdAt', descending: true)
            .get();

        return querySnapshot.docs
            .map((doc) => ShopOrder.fromJson(doc.data(), doc.id))
            .toList();
      } catch (e) {
        print('Error getting orders: $e');
        return [];
      }
  }

  // Widget để hiển thị order item
  Widget _buildOrderItem(ShopOrder order) {
    Color statusColor;
    String statusText;

    switch (order.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Chờ xác nhận';
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'Đã xác nhận';
        break;
      case 'shipping':
        statusColor = Colors.purple;
        statusText = 'Đang giao';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Hoàn tất';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusText = order.status;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullOrdersManagementPage(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID và Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn #${order.orderId?.substring(order.orderId!.length - 6).toUpperCase() ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Thông tin khách hàng
            Text(
              'Khách: ${order.shippingName}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'SĐT: ${order.shippingPhone}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Địa chỉ: ${order.shippingAddress}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget để hiển thị danh sách đơn hàng
  Widget _buildOrdersList(String status) {
    return FutureBuilder<List<ShopOrder>>(
      future: getOrdersByStatus(status, selectedMonth, selectedYear),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi: ${snapshot.error}'),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              'Không có đơn hàng',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderItem(orders[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Quản lí đơn hàng'),
      centerTitle: true,
      backgroundColor: Colors.grey[800],
      elevation: 0,
    ),
    body: Column(  // ← Bọc trong Column để có 2 phần: Filter + Tabs
      children: [
        // 1. Phần Filter (Tháng/Năm)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Dropdown chọn tháng
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('Tháng ${index + 1}'),
                      );
                    }),
                    onChanged: (newMonth) {
                      setState(() => selectedMonth = newMonth!);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Dropdown chọn năm
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text('Năm $year'),
                      );
                    }),
                    onChanged: (newYear) {
                      setState(() => selectedYear = newYear!);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 2. Phần Tabs + List (dùng Expanded vì nằm trong Column)
        Expanded(
          child: DefaultTabController(
            length: 5,
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,  // Ẩn AppBar mặc định
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Chờ xác nhận'),
                    Tab(text: 'Đã xác nhận'),
                    Tab(text: 'Đang giao'),
                    Tab(text: 'Hoàn tất'),
                    Tab(text: 'Đã hủy'),
                  ],
                  labelColor: const Color.fromARGB(255, 0, 0, 0),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList('pending'),
                  _buildOrdersList('confirmed'),
                  _buildOrdersList('shipping'),
                  _buildOrdersList('completed'),
                  _buildOrdersList('cancelled'),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }
}