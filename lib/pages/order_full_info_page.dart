import 'package:flutter/material.dart';
import 'package:flutter_clothingapp/models/order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_clothingapp/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


//UI FOR USER
class OrderFullInfoPage extends StatefulWidget {
  final ShopOrder order;

  const OrderFullInfoPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderFullInfoPage> createState() => _OrderFullInfoPageState();
}

class _OrderFullInfoPageState extends State<OrderFullInfoPage> {
   String? selectedCancelReason;
      bool isLoading = false;

      final List<String> cancelReasons = [
        'Đổi ý',
        'Đổi size',
        'Không phù hợp',
        'Khác'
    ];
    void _showCancelReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chọn lý do hủy đơn hàng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: cancelReasons.map((reason) {
                  return RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: selectedCancelReason,
                    onChanged: (String? value) {
                      setState(() {
                        selectedCancelReason = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: selectedCancelReason == null
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await _submitCancelOrder();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Xác nhận hủy'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
    Future<void> _submitCancelOrder() async {
    if (selectedCancelReason == null) return;

    setState(() => isLoading = true);

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      await FirestoreService.cancelOrder(widget.order.orderId!);
      
      await FirestoreService.createCancelLog(
        userId: userId,
        orderId: widget.order.orderId!,
        cancelReason: selectedCancelReason!,
        userEmail: widget.order.userEmail,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hủy đơn hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }
  // Kiểm tra xem user hiện tại có phải admin không
Future<bool> _checkIfAdmin() async {
  try {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    final userData = doc.data() as Map<String, dynamic>?;
    return userData?['role'] == 'admin' ?? false;
  } catch (e) {
    print('Lỗi kiểm tra admin: $e');
    return false;
  }
}

// Dialog chọn trạng thái thanh toán
void _showPaymentStatusDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Cập nhật tình trạng thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Chưa thanh toán'),
              value: 'No',
              groupValue: widget.order.paymentstatus,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('Đã thanh toán'),
              value: 'Yes',
              groupValue: widget.order.paymentstatus,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      );
    },
  ).then((selectedStatus) async {
    if (selectedStatus != null && selectedStatus != widget.order.paymentstatus) {
      await _updatePaymentStatus(selectedStatus);
    }
  });
}

// Cập nhật payment status
Future<void> _updatePaymentStatus(String newStatus) async {
  setState(() => isLoading = true);
  
  try {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.order.orderId)
        .update({'paymentstatus': newStatus});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật trạng thái thành: ${newStatus == 'Yes' ? 'Đã thanh toán' : 'Chưa thanh toán'}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() => isLoading = false);
  }
}

  String _getOrderCode() {
      if (widget.order.orderId == null || widget.order.orderId!.length < 6) {
        return widget.order.orderId ?? 'N/A';
      }
      return widget.order.orderId!.substring(widget.order.orderId!.length - 6).toUpperCase();
  }

  Color _getStatusColor() {
    switch (widget.order.status) {
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

  String _getStatusText() {
    switch (widget.order.status) {
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
        return widget.order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn #${_getOrderCode()}'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Danh sách sản phẩm
              const Text(
                'Sản phẩm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.order.items.length,
                itemBuilder: (context, index) {
                  final item = widget.order.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Hình ảnh (placeholder)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: item.imageUrl.isNotEmpty
                              ? Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image, color: Colors.grey);
                                  },
                                )
                              : const Icon(Icons.image, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          // Thông tin sản phẩm
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Giá: \$${item.price}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Số lượng: x${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                // Nếu có size đã chọn, hiển thị thêm
                                const SizedBox(height: 4),
                                Text(
                                  'Size: ${item.selectedSize ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tổng tiền item
                          Text(
                            '\$${(double.parse(item.price) * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 25),

              // Thông tin người nhận
              const Text(
                'Thông tin người nhận',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                widget.order.userEmail,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Người nhận',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                widget.order.shippingName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Số điện thoại',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                widget.order.shippingPhone,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Địa chỉ giao hàng',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                widget.order.shippingAddress,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 25),
             


                  // Thông tin thanh toán
                  const Text(
                    'Thông tin thanh toán',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.payment, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Phương thức thanh toán',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    widget.order.paymentway == 'Khinhanhang' 
                                      ? 'Thanh toán khi nhận hàng' 
                                      : 'Thanh toán chuyển khoản',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Hiển thị nội dung chuyển khoản nếu phương thức là "Chuyenkhoang"
                        
                       if (widget.order.paymentway == 'Chuyenkhoang' && widget.order.ndck != null && widget.order.ndck!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.account_balance, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nội dung chuyển khoản',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.order.ndck!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Trạng thái thanh toán',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: widget.order.paymentstatus == 'Yes' 
                                        ? Colors.green[50] 
                                        : Colors.orange[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.order.paymentstatus == 'Yes' ? 'Đã thanh toán' : 'Chưa thanh toán',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: widget.order.paymentstatus == 'Yes' 
                                          ? Colors.green 
                                          : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Thêm phần này nếu là admin
                        FutureBuilder<bool>(
                          future: _checkIfAdmin(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            
                            if (snapshot.data == true) {
                              return Column(
                                children: [
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: isLoading ? null : () => _showPaymentStatusDialog(context),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Cập nhật trạng thái'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 45),
                                    ),
                                  ),
                                ],
                              );
                            }
                            
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 25),
              const Divider(),
              const SizedBox(height: 25),

              // Nút hủy đơn hàng (chỉ hiển thị nếu status là 'pending')
              if (widget.order.status == 'pending')
                ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _showCancelReasonDialog(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Hủy đơn hàng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              const SizedBox(height: 25),

              // Tổng tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng tiền:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}