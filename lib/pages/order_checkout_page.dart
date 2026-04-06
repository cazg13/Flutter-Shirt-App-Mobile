import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:flutter_clothingapp/models/order.dart';
import 'package:flutter_clothingapp/models/user_profile.dart';
import 'package:flutter_clothingapp/repositories/order_repository.dart';
import 'package:flutter_clothingapp/repositories/user_firestore_repo.dart';
import 'package:provider/provider.dart';
import 'package:flutter_clothingapp/pages/payment_way_page.dart';

class OrderCheckoutPage extends StatefulWidget {
  const OrderCheckoutPage({super.key});

  @override
  State<OrderCheckoutPage> createState() => _OrderCheckoutPageState();
}

class _OrderCheckoutPageState extends State<OrderCheckoutPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserFirestoreRepo _userFirestoreRepo = UserFirestoreRepo();
  final OrderRepository _orderRepository = OrderRepository();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    
    // Lấy thông tin user từ Firestore để pre-fill
    _loadUserProfile();
  }

  // Hàm lấy thông tin user từ Firestore
  Future<void> _loadUserProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        UserProfile? userProfile = await _userFirestoreRepo.getUserProfile(currentUser.uid);
        
        if (userProfile != null) {
          // Pre-fill các TextFields
          _nameController.text = userProfile.name;
          _phoneController.text = userProfile.phone;
          _addressController.text = userProfile.address;
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Hàm kiểm tra validation
  bool _validateInputs() {
    if (_nameController.text.isEmpty) {
      _showErrorSnackBar('Hãy nhập tên của bạn');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Hãy nhập số điện thoại của bạn');
      return false;
    }
    if (_addressController.text.isEmpty) {
      _showErrorSnackBar('Hãy nhập địa chỉ của bạn');
      return false;
    }
    return true;
  }

  // Hàm lưu order lên Firebase
  Future<void> _completeOrder() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      User? currentUser = _auth.currentUser;
      Cart cart = Provider.of<Cart>(context, listen: false);

      if (currentUser == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      if (cart.getUserCart().isEmpty) {
        _showErrorSnackBar('Cart is empty');
        return;
      }

      // Tạo list ShopOrderItems từ cart
      List<ShopOrderItem> orderItems = cart.getUserCart().map((shirt) {
        return ShopOrderItem(
          productDocId: shirt.id,  // Document ID từ Firebase
          productCode: shirt.id,
          name: shirt.name,
          price: shirt.price,
          quantity: shirt.quantity,
          imageUrl: shirt.imageUrl,  // Thêm imageUrl vào order item
          selectedSize: shirt.selectedSize,  // Thêm selectedSize vào order item
        );
      }).toList();

      // Tính tổng tiền
      double totalAmount = 0;
      for (var shirt in cart.getUserCart()) {
        totalAmount += double.parse(shirt.price) * shirt.quantity;
      }

      // Tạo ShopOrder object
      ShopOrder order = ShopOrder(
        userId: currentUser.uid,
        userEmail: currentUser.email ?? '',
        shippingName: _nameController.text,
        shippingPhone: _phoneController.text,
        shippingAddress: _addressController.text,
        createdAt: DateTime.now(),
        status: 'pending',
        items: orderItems,
        totalAmount: totalAmount,
        paymentway: 'Pending',
        paymentstatus: 'No',
        

      );

      // Chuyển sang payment page (payment page sẽ lưu order vào DB)
      // Delay 500ms rồi navigate sang payment page
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWayPage(
              order: order,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to complete order: $e');
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Hàm tính tổng tiền
  double _calculateTotal() {
    Cart cart = Provider.of<Cart>(context, listen: false);
    double total = 0;
    for (var shirt in cart.getUserCart()) {
      total += double.parse(shirt.price) * shirt.quantity;
    }
    return total;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Shipping Information
                  Text(
                    'Thông tin giao hàng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name TextField
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      hintText: 'Nhập họ và tên của bạn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Phone TextField
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại của bạn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),

                  // Address TextField
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Địa chỉ giao hàng',
                      hintText: 'Nhập địa chỉ giao hàng của bạn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 40),

                  // Section: Order Summary
                  Text(
                    'Tóm tắt đơn hàng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hiển thị items
                  Consumer<Cart>(
                    builder: (context, cart, child) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.getUserCart().length,
                        itemBuilder: (context, index) {
                          var shirt = cart.getUserCart()[index];
                          double itemTotal = double.parse(shirt.price) * shirt.quantity;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shirt.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Size: ${shirt.selectedSize} × ${shirt.quantity}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${itemTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng số tiền:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_calculateTotal().toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Complete Order Button
                  GestureDetector(
                    onTap: _completeOrder,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Bước tiếp theo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}