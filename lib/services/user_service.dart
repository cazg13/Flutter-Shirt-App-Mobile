import 'package:flutter_clothingapp/models/user_profile.dart';
import 'package:flutter_clothingapp/repositories/user_firestore_repo.dart';

class UserService {
  final UserFirestoreRepo userFirestoreRepo = UserFirestoreRepo();

  // Lấy user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      return await userFirestoreRepo.getUserProfile(uid);
    } catch (e) {
      throw Exception('Lỗi lấy user profile: $e');
    }
  }

  // Cập nhật user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      
      // Chỉ thêm các field được cập nhật
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      // Nếu có cái gì để update
      if (updates.isNotEmpty) {
        await userFirestoreRepo.updateUserProfile(
          uid: uid,
          updates: updates,
        );
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật user profile: $e');
    }
  }

  // Cập nhật role (admin use)
  Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    try {
      await userFirestoreRepo.updateUserProfile(
        uid: uid,
        updates: {'role': role},
      );
    } catch (e) {
      throw Exception('Lỗi cập nhật role: $e');
    }
  }
}