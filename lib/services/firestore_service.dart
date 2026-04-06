import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _shoesCollection = 'Shoe';

  /// Lấy tất cả giày từ Firestore
  static Future<List<Map<String, dynamic>>> getAllShoes() async {
    try {
      QuerySnapshot snapshot = 
          await _firestore.collection(_shoesCollection).get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error fetching shoes: $e');
      rethrow;
    }
  }

  /// Lấy 1 giày theo ID
  static Future<Map<String, dynamic>?> getShoeById(String id) async {
    try {
      DocumentSnapshot doc = 
          await _firestore.collection(_shoesCollection).doc(id).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      print('Error fetching shoe: $e');
      rethrow;
    }
  }
  // Update stock sản phẩm
    static Future<void> updateProductStock(String productId, int quantityToDeduct) async {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('Shoe')
            .doc(productId)
            .get();

        if (doc.exists) {
          int currentStock = doc['stock'] ?? 0;
          int newStock = currentStock - quantityToDeduct;

          await _firestore
              .collection('Shoe')
              .doc(productId)
              .update({'stock': newStock});
        }
      } catch (e) {
        throw Exception('Failed to update stock: $e');
      }
    }
      /// Cập nhật status của đơn hàng thành "cancelled"
  static Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore
          .collection('orders')  
          .doc(orderId)
          .update({'status': 'cancelled'});
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// Tạo CancelLog mới
  static Future<String> createCancelLog({
    required String userId,
    required String orderId,
    required String cancelReason,
    required String userEmail,
  }) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('CancelLog')
          .add({
            'userId': userId,
            'orderId': orderId,
            'cancelReason': cancelReason,
            'cancelledAt': Timestamp.fromDate(DateTime.now()),
            'userEmail': userEmail,
          });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create cancel log: $e');
    }
  }
    /// Update status của đơn hàng
   static Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? adminUid,
    String? adminEmail,
  }) async {
    try {
      Map<String, dynamic> updates = {'status': newStatus};
      
      if (newStatus == 'completed') {
        updates['paymentstatus'] = 'Yes';

        // Lấy order để update stock
        final orderDoc = await _firestore
            .collection('orders')
            .doc(orderId)
            .get();

        if (orderDoc.exists) {
          print('DEBUG: Order found: $orderId');
          final items = orderDoc['items'] as List?;
          print('DEBUG: Items: $items');
          
          if (items != null) {
            print('DEBUG: Processing ${items.length} items');
            // Update stock từng sản phẩm
            for (int i = 0; i < items.length; i++) {
              var item = items[i];
              print('DEBUG: Item $i: $item');
              
              // Thử cả productCode và productDocId
              final productCode = item['productCode'] ?? '';
              final productDocId = item['productDocId'] ?? '';
              final quantity = (item['quantity'] as int?) ?? 1;
              
              print('DEBUG: productCode=$productCode, productDocId=$productDocId, quantity=$quantity');

              // Ưu tiên dùng productCode (field 'id')
              if (productCode.isNotEmpty) {
                try {
                  print('DEBUG: Querying Shoe with id=$productCode');
                  // Query để tìm Shoe document có field 'id' = productCode
                  final querySnapshot = await _firestore
                      .collection('Shoe')
                      .where('id', isEqualTo: productCode)
                      .get();
                  
                  print('DEBUG: Query result: ${querySnapshot.docs.length} documents found');
                  
                  if (querySnapshot.docs.isNotEmpty) {
                    // Lấy document ID thực của Shoe
                    final shoeDocId = querySnapshot.docs.first.id;
                    print('DEBUG: Found Shoe docId=$shoeDocId, updating stock -$quantity');
                    
                    // Update stock dùng document ID
                    await _firestore
                        .collection('Shoe')
                        .doc(shoeDocId)
                        .update({
                          'stock': FieldValue.increment(-quantity),
                        });
                    print('✅ Updated stock for product $productCode: -$quantity');
                  } else {
                    print('❌ Warning: Product with id $productCode not found');
                  }
                } catch (e) {
                  print('❌ Error updating stock for product $productCode: $e');
                }
              } else {
                print('⚠️ productCode is empty. productDocId=$productDocId');
              }
            }
          } else {
            print('⚠️ No items found in order');
          }

          // Tạo CompleteLog
          if (adminUid != null && adminEmail != null) {
            try {
              await createCompleteLog(
                orderId: orderId,
                adminUid: adminUid,
                adminEmail: adminEmail,
              );
            } catch (e) {
              print('Warning: Failed to create complete log: $e');
            }
          }
        }
      }
      
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
    /// Thêm sản phẩm mới
  static Future<void> addProduct({
     required String id,
    required String name,
    required String price,
    required int stock,
    required String imageUrl,
    required String description,
    required List<String> sizes,
  }) async {
    try {
      await _firestore.collection('Shoe').add({
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'description': description,
        'sizes': sizes,
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  /// Xóa sản phẩm
  static Future<void> deleteProduct(String docId) async {
    try {
      await _firestore.collection('Shoe').doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Lấy lý do hủy từ CancelLog theo orderId
static Future<String?> getCancelReason(String orderId) async {
  try {
    QuerySnapshot snapshot = await _firestore
        .collection('CancelLog')
        .where('orderId', isEqualTo: orderId)
        .limit(1)  // Lấy 1 record gần nhất
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['cancelReason'] ?? '';
    }
    return null;  // Không có lý do hủy
  } catch (e) {
    throw Exception('Failed to get cancel reason: $e');
  }
}

/// Cập nhật lý do hủy (nếu admin thêm sau)
static Future<void> updateCancelReason(String orderId, String cancelReason, String userId, String userEmail) async {
  try {
    // Kiểm tra xem có CancelLog của order này chưa
    QuerySnapshot snapshot = await _firestore
        .collection('CancelLog')
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      // Update existing
      await _firestore
          .collection('CancelLog')
          .doc(snapshot.docs.first.id)
          .update({'cancelReason': cancelReason});
    } else {
      // Create new
      await _firestore
          .collection('CancelLog')
          .add({
            'userId': userId,
            'orderId': orderId,
            'cancelReason': cancelReason,
            'cancelledAt': Timestamp.fromDate(DateTime.now()),
            'userEmail': userEmail,
          });
    }
    } catch (e) {
      throw Exception('Failed to update cancel reason: $e');
    }
  }
    /// Tạo CompleteLog mới
  static Future<String> createCompleteLog({
    required String orderId,
    required String adminUid,
    required String adminEmail,
  }) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('CompleteLog')
          .add({
            'orderId': orderId,
            'adminUid': adminUid,
            'adminEmail': adminEmail,
            'completedAt': Timestamp.fromDate(DateTime.now()),
          });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create complete log: $e');
    }
  }
}
