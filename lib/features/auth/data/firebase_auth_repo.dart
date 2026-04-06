/*
FIREBASE IS OUR BACKEND - CAN SWAP OUT ANY BACKEND HERE
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_clothingapp/features/auth/domain/entities/app_user.dart';
import 'package:flutter_clothingapp/features/auth/domain/repos/auth_repo.dart';
import 'package:flutter_clothingapp/models/user_profile.dart'; 
import 'package:flutter_clothingapp/repositories/user_firestore_repo.dart'; 

class FirebaseAuthRepo implements AuthRepo{

  //ACCESS TO FIREBASE AUTH INSTANCE HERE
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserFirestoreRepo userFirestoreRepo = UserFirestoreRepo();

  //DELETE ACCOUNT
  @override
  Future<void> deleteAccount() async {
    try{
      //get current user
      final user = firebaseAuth.currentUser;
      //check user not null
      if(user == null)
        throw Exception('No user logged in');
      
      //delete user from firebase auth
        await user.delete();
      //logout from app
        await logout();
    }
    catch(e){
      throw Exception('Delete account error: $e');
    }
  }

  //GET CURRENT USER
  @override
  Future<AppUser?> getCurrentUser() async{
    //get current user from firebase auth
    final firebaseUser = firebaseAuth.currentUser;
    //no logged in user
    if(firebaseUser == null)
      return null;

    //logged in user found
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!
    );
  }

  //LOGIN : Email + Password
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
        //attempt sign in
        UserCredential userCredential = await 
        firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        //create User
        AppUser user =AppUser(uid: userCredential.user!.uid, email: email,);
        return user;
    }
    //catch any errors
    on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        throw Exception('Tài khoản không tồn tại');
      }
      else if(e.code == 'wrong-password'){
        throw Exception('Bạn đã điền sai mật khẩu hoặc tài khoản');
      }
      else if(e.code == 'invalid-email'){
        throw Exception('Email không hợp lệ');
      }
      else{
        throw Exception('Bạn đã điền sai mật khẩu hoặc tài khoản');
      }
    }
    catch(e){
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  //LOGOUT
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  //REGISTER : Email + Password + Name
  @override
  Future<AppUser?> registerWithEmailPassword(
    String name, String email, String password) async {
    try {
      //attempt registration
      UserCredential userCredential = await 
      firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

            // Lấy uid từ Firebase Auth
        String uid = userCredential.user!.uid;
        
        // Tạo user profile trong Firestore
        await userFirestoreRepo.createUserProfile(
          uid: uid,
          email: email,
        );
      //create User
      AppUser user =AppUser(uid: userCredential.user!.uid, email: email,);
      return user;

    //catch any errors
    }
    catch(e){
      throw Exception('Registration error: $e');
    }
   
  }

  //RESET THE PASSWORD
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try{
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent!';

    }
    catch(e){
      throw Exception('Send password reset email error: $e');
    }
  }

}