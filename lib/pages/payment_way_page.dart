import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_clothingapp/models/order.dart';
import 'package:flutter_clothingapp/repositories/order_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_clothingapp/models/cart.dart';

class PaymentWayPage extends StatefulWidget {
  final ShopOrder order;
  

  const PaymentWayPage({
    super.key,
    required this.order,
   
  });

  @override
  State<PaymentWayPage> createState() => _PaymentWayPageState();
}

class _PaymentWayPageState extends State<PaymentWayPage> {
  late ShopOrder _currentOrder;
  bool _expandBankInfo = false;
  bool _isLoading = false;

  final OrderRepository _orderRepository = OrderRepository();

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  // Hàm complete order với payment info
  Future<void> _completeOrderWithPayment() async {
    if (_currentOrder.paymentway == 'Pending') {
      _showErrorSnackBar('Please select payment method');
      return;
    }

    setState(() => _isLoading = true);

    try {
        // Generate NDCK nếu phương thức là chuyển khoản
        String? ndck;
        if (_currentOrder.paymentway == 'Chuyenkhoang') {
          int orderCount = await _getUserOrderCount();
          ndck = _generateOrderCode(_currentOrder.userId, orderCount);
        }

        // Tạo order với NDCK
        ShopOrder orderWithNdck = ShopOrder(
          orderId: _currentOrder.orderId,
          userId: _currentOrder.userId,
          userEmail: _currentOrder.userEmail,
          shippingName: _currentOrder.shippingName,
          shippingPhone: _currentOrder.shippingPhone,
          shippingAddress: _currentOrder.shippingAddress,
          createdAt: _currentOrder.createdAt,
          status: _currentOrder.status,
          items: _currentOrder.items,
          totalAmount: _currentOrder.totalAmount,
          paymentway: _currentOrder.paymentway,
          paymentstatus: _currentOrder.paymentstatus,
          ndck: ndck,  // Thêm NDCK vào đây
        );

        String orderId = await _orderRepository.createOrder(orderWithNdck);
        print('Order created with ID: $orderId');
        
        Cart cart = Provider.of<Cart>(context, listen: false);
        cart.userCart.clear();
        cart.notifyListeners();

        _showSuccessSnackBar('Đặt hàng thành công!');
        
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        _showErrorSnackBar('Đặt hàng thất bại: $e');
        print('Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
  }
  String _generateOrderCode(String userId, int orderIndex) {
  // Lấy 5 chữ cuối của userId
  String lastFiveUserId = userId.length >= 5 
      ? userId.substring(userId.length - 5).toUpperCase()
      : userId.toUpperCase();
  
  return 'CKDH$lastFiveUserId$orderIndex';
}
// Hàm lấy số lượng đơn hàng của user để tạo mã đơn hàng duy nhất
Future<int> _getUserOrderCount() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: _currentOrder.userId)
        .get();
    
    return querySnapshot.docs.length;
  } catch (e) {
    print('Lỗi lấy số đơn hàng: $e');
    return 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phương thức thanh toán'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tile 1: Thanh toán khi nhận hàng
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentOrder = ShopOrder(
                          orderId: _currentOrder.orderId,
                          userId: _currentOrder.userId,
                          userEmail: _currentOrder.userEmail,
                          shippingName: _currentOrder.shippingName,
                          shippingPhone: _currentOrder.shippingPhone,
                          shippingAddress: _currentOrder.shippingAddress,
                          createdAt: _currentOrder.createdAt,
                          status: _currentOrder.status,
                          items: _currentOrder.items,
                          totalAmount: _currentOrder.totalAmount,
                          paymentway: 'Khinhanhang',
                          paymentstatus: 'No',
                        
                        );
                        _expandBankInfo = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentOrder.paymentway == 'Khinhanhang'
                              ? Colors.green
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'Khinhanhang',
                            groupValue: _currentOrder.paymentway,
                            onChanged: (value) {
                              setState(() {
                                _currentOrder = ShopOrder(
                                  orderId: _currentOrder.orderId,
                                  userId: _currentOrder.userId,
                                  userEmail: _currentOrder.userEmail,
                                  shippingName: _currentOrder.shippingName,
                                  shippingPhone: _currentOrder.shippingPhone,
                                  shippingAddress: _currentOrder.shippingAddress,
                                  createdAt: _currentOrder.createdAt,
                                  status: _currentOrder.status,
                                  items: _currentOrder.items,
                                  totalAmount: _currentOrder.totalAmount,
                                  paymentway: 'Khinhanhang',
                                  paymentstatus: 'No',
                                
                                );
                                _expandBankInfo = false;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Thanh toán khi nhận hàng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tile 2: Thanh toán chuyển khoản
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandBankInfo = !_expandBankInfo;
                        _currentOrder = ShopOrder(
                          orderId: _currentOrder.orderId,
                          userId: _currentOrder.userId,
                          userEmail: _currentOrder.userEmail,
                          shippingName: _currentOrder.shippingName,
                          shippingPhone: _currentOrder.shippingPhone,
                          shippingAddress: _currentOrder.shippingAddress,
                          createdAt: _currentOrder.createdAt,
                          status: _currentOrder.status,
                          items: _currentOrder.items,
                          totalAmount: _currentOrder.totalAmount,
                          paymentway: 'Chuyenkhoang',
                          paymentstatus: 'No',
                        
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentOrder.paymentway == 'Chuyenkhoang'
                              ? Colors.green
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Chuyenkhoang',
                                groupValue: _currentOrder.paymentway,
                                onChanged: (value) {
                                  setState(() {
                                    _currentOrder = ShopOrder(
                                      orderId: _currentOrder.orderId,
                                      userId: _currentOrder.userId,
                                      userEmail: _currentOrder.userEmail,
                                      shippingName: _currentOrder.shippingName,
                                      shippingPhone: _currentOrder.shippingPhone,
                                      shippingAddress: _currentOrder.shippingAddress,
                                      createdAt: _currentOrder.createdAt,
                                      status: _currentOrder.status,
                                      items: _currentOrder.items,
                                      totalAmount: _currentOrder.totalAmount,
                                      paymentway: 'Chuyenkhoang',
                                      paymentstatus: 'No',
                                     
                                    );
                                    _expandBankInfo = true;
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Thanh toán chuyển khoản',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (_expandBankInfo && _currentOrder.paymentway == 'Chuyenkhoang')
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bank Transfer Information',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildBankInfoRow('Ngân hàng:', 'MB Bank'),
                                    _buildBankInfoRow('Tên tài khoản:', 'Phạm Trung Tín'),
                                    _buildBankInfoRow('Số tài khoản:', '0002042621895'),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Nội dung chuyển khoản:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    FutureBuilder<int>(
                                      future: _getUserOrderCount(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Đang tải...');
                                        }
                                        
                                        String transferContent = _generateOrderCode(
                                          _currentOrder.userId,
                                          snapshot.data ?? 0,
                                        );
                                        
                                        return Text(
                                          transferContent,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Complete Order Button
                  GestureDetector(
                    onTap: _completeOrderWithPayment,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Hoàn tất đơn hàng',
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

  Widget _buildBankInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}