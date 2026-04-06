import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_clothingapp/models/order.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String ordersCollection = 'orders';

  // Lưu order lên Firebase
  Future<String> createOrder(ShopOrder order) async {
    try {
      // Auto-generate document ID
      DocumentReference docRef = await _firestore
          .collection(ordersCollection)
          .add(order.toJson());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Lấy các orders của user
  Future<List<ShopOrder>> getUserOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ShopOrder.fromJson(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {throw Exception('Failed to fetch orders: $e');
    }
  }

  // Lấy chi tiết 1 order
  Future<ShopOrder?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(ordersCollection)
          .doc(orderId)
          .get();

      if (doc.exists) {
        return ShopOrder.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  // Update status order
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection(ordersCollection)
          .doc(orderId)
          .update({'status': newStatus});
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }
}