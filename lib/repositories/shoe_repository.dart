import 'package:flutter_clothingapp/models/shoe.dart';
import 'package:flutter_clothingapp/services/firestore_service.dart';

class ShoeRepository {
  /// Lấy tất cả giày từ database
  Future<List<Shoe>> getAllShoes() async {
    try {
      List<Map<String, dynamic>> data = 
          await FirestoreService.getAllShoes();
      return data.map((item) => Shoe.fromFirebase(item, item['id'])).toList();
    } catch (e) {
      print('Repository Error: $e');
      rethrow;
    }
  }

  /// Lấy 1 giày theo ID
  Future<Shoe?> getShoeById(String id) async {
    try {
      Map<String, dynamic>? data = 
          await FirestoreService.getShoeById(id);
      if (data == null) return null;
      return Shoe.fromFirebase(data, id);
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
