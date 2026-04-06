import 'package:cloud_firestore/cloud_firestore.dart';

class ShopOrderItem {
  final String productDocId;      // Document ID từ Firestore
  final String productCode;        // id của Shoe
  final String name;              // Tên giày
  final String price;             // Giá
  final int quantity;        //Số lượng
  final String imageUrl;     // Giá
  final String? selectedSize; // Size đã chọn (nếu có)

  ShopOrderItem({
    required this.productDocId,
    required this.productCode,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.selectedSize,
  });

  // Convert to JSON để lưu Firebase
  Map<String, dynamic> toJson() {
    return {
      'productDocId': productDocId,
      'productCode': productCode,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'selectedSize': selectedSize,
    };
  }

  // Convert từ JSON
  factory ShopOrderItem.fromJson(Map<String, dynamic> json) {
    return ShopOrderItem(
      productDocId: json['productDocId'] ?? '',
      productCode: json['productCode'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '0',
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      selectedSize: json['selectedSize'],  // Có thể null
    );
  }
}

class ShopOrder {
  final String? orderId;          // Auto-generate khi tạo
  final String userId;            // uid của User document
  final String userEmail;         // Email của User
  final String shippingName;      // Tên người nhận
  final String shippingPhone;     // SĐT người nhận
  final String shippingAddress;   // Địa chỉ nhận hàng
  final DateTime createdAt;
  final String status;            // pending, confirmed, shipping, completed, cancelled
  final List<ShopOrderItem> items;    // Danh sách giày
  final double totalAmount;   
  final String paymentway;       // "Khinhanhang" hoặc "Chuyenkhoang"
  final String paymentstatus;   // Tổng tiền
  final String? ndck; 
 

  ShopOrder({
    this.orderId,
    required this.userId,
    required this.userEmail,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.paymentway,
    required this.paymentstatus,
    this.ndck,
   
  });

  // Convert to JSON để lưu Firebase
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'shippingName': shippingName,
      'shippingPhone': shippingPhone,
      'shippingAddress': shippingAddress,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentway': paymentway,
      'paymentstatus': paymentstatus,
      'ndck': ndck,
    };
  }

  // Convert từ Firebase
  factory ShopOrder.fromJson(Map<String, dynamic> json, String orderId) {
    return ShopOrder(
      orderId: orderId,
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      shippingName: json['shippingName'] ?? '',
      shippingPhone: json['shippingPhone'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      status: json['status'] ?? 'pending',
      items: (json['items'] as List?)
          ?.map((item) => ShopOrderItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentway: json['paymentway'] ?? 'Khinhanhang',
      paymentstatus: json['paymentstatus'] ?? 'No',
      ndck: json['ndck'],
    );
  }
}