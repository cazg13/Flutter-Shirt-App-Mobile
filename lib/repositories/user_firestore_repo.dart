import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_clothingapp/models/user_profile.dart';

class UserFirestoreRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String usersCollection = 'users';

  // Tạo user profile mới trong Firestore sau khi đăng ký
  Future<void> createUserProfile({
    required String uid,
    required String email,
  }) async {
    try {
      UserProfile userProfile = UserProfile(
        uid: uid,
        email: email,
        role: 'customer',  // Mặc định role là customer
        createdAt: DateTime.now(),
        name: '',          // Ban đầu để trống
        phone: '',         // Ban đầu để trống
        address: '',       // Ban đầu để trống
      );

      // Lưu vào Firestore: collection 'users' -> document với id = uid
      await firestore
          .collection(usersCollection)
          .doc(uid)
          .set(userProfile.toJson());
    } catch (e) {
      throw Exception('Lỗi tạo user profile: $e');
    }
  }

  // Lấy user profile từ Firestore
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await firestore
          .collection(usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy user profile: $e');
    }
  }

  // Cập nhật user profile
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await firestore
          .collection(usersCollection)
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw Exception('Lỗi cập nhật user profile: $e');
    }
  }
}