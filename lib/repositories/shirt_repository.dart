import 'package:flutter_clothingapp/models/shirt.dart';
import 'package:flutter_clothingapp/services/firestore_service.dart';

class ShirtRepository {
  /// Lấy tất cả giày từ database
  Future<List<Shirt>> getAllShirts() async {
    try {
      List<Map<String, dynamic>> data = 
          await FirestoreService.getAllShirts();
      return data.map((item) => Shirt.fromFirebase(item, item['id'])).toList();
    } catch (e) {
      print('Repository Error: $e');
      rethrow;
    }
  }

  /// Lấy 1 giày theo ID
  Future<Shirt?> getShirtById(String id) async {
    try {
      Map<String, dynamic>? data = 
          await FirestoreService.getShirtById(id);
      if (data == null) return null;
      return Shirt.fromFirebase(data, id);
    } catch (e) {
      print('Repository Error: $e');
      rethrow;
    }
  }
 // Update stock sau khi checkout
    Future<void> updateProductStock(String productId, int quantityToDeduct) async {
      try {
        await FirestoreService.updateProductStock(productId, quantityToDeduct);
      } catch (e) {
        throw Exception('Failed to update stock: $e');
      }
    }
}
