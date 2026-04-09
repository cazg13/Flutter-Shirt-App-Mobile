import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_clothingapp/pages/Dashboard/orders_management_page.dart';
import 'package:flutter_clothingapp/pages/Dashboard/products_management_page.dart';
import 'package:flutter_clothingapp/pages/Dashboard/searchorders_page.dart';
import 'package:flutter_clothingapp/pages/Dashboard/users_management_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_clothingapp/pages/Dashboard/log_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Method lấy số đơn hàng trong tháng hiện tại
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  

  // Method lấy tổng user của app
  Future<int> getTotalUsers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .get();
      return querySnapshot.size;
    } catch (e) {
      print('Error getting total users: $e');
      return 0;
    }
  }
  //Method lấy số đơn hàng trong tháng hiện tại
  Future<int> getOrdersThisMonth(int month, int year) async {
    try {
      final firstDayOfMonth = DateTime(year, month, 1);
      final firstDayOfNextMonth = month == 12 
          ? DateTime(year + 1, 1, 1)
          : DateTime(year, month + 1, 1);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .where('createdAt',
              isLessThan: Timestamp.fromDate(firstDayOfNextMonth))
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error getting orders this month: $e');
      return 0;
    }
  }

  // Method lấy tổng doanh thu (từ các order completed)
   Future<double> getTotalRevenue(int month, int year) async {
    try {
      final firstDayOfMonth = DateTime(year, month, 1);
      final firstDayOfNextMonth = month == 12 
          ? DateTime(year + 1, 1, 1)
          : DateTime(year, month + 1, 1);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'completed')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .where('createdAt',
              isLessThan: Timestamp.fromDate(firstDayOfNextMonth))
          .get();

      double totalRevenue = 0;
      for (var doc in querySnapshot.docs) {
        final totalAmount = doc['totalAmount'];
        if (totalAmount != null) {
          totalRevenue += (totalAmount is int ? totalAmount.toDouble() : totalAmount as double);
        }
      }

      return totalRevenue;
    } catch (e) {
      print('Error getting total revenue: $e');
      return 0;
    }
  }
  // Method lấy tổng sản phẩm đang kinh doanh
  Future<int> getTotalProducts() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Shirt').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error getting total products: $e');
      return 0;
    }
  }

  // Widget StatCard để hiển thị từng stat
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[800],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  child: Image.asset(
                    'lib/images/nike-5-logo.png',
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                    color: Colors.grey[700],
                  ),
                ),
                // Quản lí đơn hàng
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersManagementPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Quản lí đơn hàng',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Quản lí sản phẩm
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductsManagementPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.inventory,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Quản lí sản phẩm',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                  // Nhập hàng
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showImportStockDialog(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.add_circle,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Nhập hàng',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Quản lí người dùng
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsersManagementPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.people,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Quản lí người dùng',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Logs
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.history,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Quản lí Logs',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Tra cứu sản phẩm
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchOrderPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.history,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Tra cứu sản phẩm',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Logout button
            Padding(
              padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const ListTile(
                  leading: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Quay lại',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
       child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng quan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
               // Row chọn tháng/năm
              Row(
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
                            child: Text(
                              'Tháng ${index + 1}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }),
                        onChanged: (newMonth) {
                          setState(() => selectedMonth = newMonth!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

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
                            child: Text(
                              'Năm $year',
                              style: const TextStyle(fontSize: 14),
                            ),
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
              const SizedBox(height: 25),

              // Grid 2x2 cho 4 stat cards
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: [
                  // Card 1: Đơn hàng tháng này
                  FutureBuilder<int>(
                    future: getOrdersThisMonth(selectedMonth, selectedYear),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatCard(
                          'Đơn hàng\ntháng này',
                          '...',
                          Colors.blue,
                        );
                      }
                      final ordersCount = snapshot.data ?? 0;
                      return _buildStatCard(
                        'Đơn hàng\ntháng này',
                        '$ordersCount',
                        Colors.blue,
                      );
                    },
                  ),

                  // Card 2: Tổng User
                  FutureBuilder<int>(
                    future: getTotalUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatCard(
                          'Tổng\nKhách hàng',
                          '...',
                          Colors.green,
                        );
                      }
                      final usersCount = snapshot.data ?? 0;
                      return _buildStatCard(
                        'Tổng\nKhách hàng',
                        '$usersCount',
                        Colors.green,
                      );
                    },
                  ),

                  // Card 3: Sản phẩm
                  FutureBuilder<int>(
                    future: getTotalProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatCard(
                          'Sản phẩm\nđang bán',
                          '...',
                          Colors.purple,
                        );
                      }
                      final productsCount = snapshot.data ?? 0;
                      return _buildStatCard(
                        'Sản phẩm\nđang bán',
                        '$productsCount',
                        Colors.purple,
                      );
                    },
                  ),

                  // Card 4: Tổng Doanh thu
                  FutureBuilder<double>(
                    future: getTotalRevenue(selectedMonth, selectedYear),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildStatCard(
                          'Tổng\nDoanh thu',
                          '...',
                          Colors.orange,
                        );
                      }
                      final revenue = snapshot.data ?? 0;
                      return _buildStatCard(
                        'Tổng\nDoanh thu',
                        '\$${revenue.toStringAsFixed(2)}',
                        Colors.orange,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
    // Hiển thị dialog nhập hàng
  Future<void> _showImportStockDialog(BuildContext context) async {
    String? selectedDocumentId;  // DocumentID dài
    String? selectedShirtDataId;  // Shirt data id ('004', '005', ...)
    String? selectedProductName;
    final TextEditingController quantityController = TextEditingController();
    List<Map<String, dynamic>> products = [];

    // Lấy danh sách sản phẩm từ Firestore
    try {
      QuerySnapshot snapshot = 
          await FirebaseFirestore.instance.collection('Shirt').get();
      products = snapshot.docs
          .map((doc) => {
            'documentId': doc.id,
            'shirtDataId': doc['id'] ?? '', 
            'name': doc['name'] ?? 'Unknown',
          })
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nhập hàng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown chọn sản phẩm
                DropdownButton<String>(
                  hint: const Text('Chọn sản phẩm'),
                  value: selectedDocumentId,
                  isExpanded: true,
                  items: products.map((product) {
                    return DropdownMenuItem<String>(
                      value: product['documentId'],
                      child: Text(
                        '${product['name']} (${product['shirtDataId']})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDocumentId = value;
                      if (value != null) {
                        final product = products.firstWhere(
                          (p) => p['documentId'] == value,
                          orElse: () => {},
                        );
                        selectedProductName = product['name'];
                        selectedShirtDataId = product['shirtDataId'];
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                // TextInput nhập số lượng
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Số lượng nhập',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDocumentId == null || 
                    quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn sản phẩm và nhập số lượng'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                int quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Số lượng phải > 0'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Gọi hàm update stock, truyền cả documentId và shirtDataId
                _handleImportStock(
                  selectedDocumentId!,
                  selectedShirtDataId!,
                  quantity,
                );
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xử lý nhập hàng
  Future<void> _handleImportStock(String documentId, String shirtDataId, int quantity) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final adminEmail = user?.email ?? 'unknown@example.com';

      // 1. Update stock sản phẩm (dùng documentId)
      await FirebaseFirestore.instance
          .collection('Shirt')
          .doc(documentId)
          .update({
        'stock': FieldValue.increment(quantity),
      });

      // 2. Tạo ImportStockLog (lưu shirtDataId)
      await FirebaseFirestore.instance
          .collection('ImportStockLog')
          .add({
        'productId': shirtDataId,  // ← Lưu Shirt data id ('004', '005', ...)
        'stockAdded': quantity,
        'importedAt': Timestamp.now(),
        'adminEmail': adminEmail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nhập hàng thành công! Thêm $quantity sản phẩm'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error: $e');
    }
  }
}