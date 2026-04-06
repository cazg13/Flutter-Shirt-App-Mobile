/*
Cubits are reponsible for state management 
*/

import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/features/auth/domain/entities/app_user.dart';
import 'package:flutter_clothingapp/features/auth/domain/repos/auth_repo.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_clothingapp/models/user_profile.dart';  
import 'package:flutter_clothingapp/services/user_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  final UserService userService = UserService();

  AppUser? _currentUser;
  UserProfile? _currentUserProfile;
  AuthCubit({required this.authRepo}) : super(AuthInitial());

  //get current user
  AppUser? get currentUser => _currentUser;

  //get current user profile
  UserProfile? get currentUserProfile => _currentUserProfile;

  //check if user is authenticated
  void checkAuth() async {
    //loading
    emit(AuthLoading());

    //get current user
    final AppUser? user = await authRepo.getCurrentUser();

    if(user !=null)
    {
      _currentUser = user;
      try {
        _currentUserProfile = await userService.getUserProfile(user.uid);
      } catch (e) {
        print('Lỗi load profile: $e');
      }
      // ← Hết phần thêm
      emit(Authenticated(user));
    }
    else{
      emit(Unauthenticated());
    }
  }

  //login with email + password
  Future<void> login(String email,String pw) async {
    try{
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);
      if(user != null){
        _currentUser = user;
         try {
          _currentUserProfile = await userService.getUserProfile(user.uid);
        } catch (e) {
          print('Lỗi load profile: $e');
        }
        emit(Authenticated(user));
      }
      else{
        emit(Unauthenticated());
      }
    }
    catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  //register with email + password + name
 Future<void> register(String name, String email, String pw) async {
  try {
    emit(AuthLoading());
    final user = await authRepo.registerWithEmailPassword(name, email, pw);
    if (user != null) {
      try {
        _currentUserProfile = await userService.getUserProfile(user.uid);
      } catch (e) {
        print('Lỗi load profile sau signup: $e');
      }
      // Emit success state
      emit(RegisterSuccess('Đăng kí thành công! Vui lòng đăng nhập.'));
      
      // Logout user
      await authRepo.logout();
      // Emit unauthenticated to go back to login
      emit(Unauthenticated());
    }
  } catch (e) {
    emit(AuthError(e.toString()));
    emit(Unauthenticated());
  }
}

  //logout
  Future<void> logout() async {
    emit(AuthLoading());
    await authRepo.logout();
    _currentUser = null;  
    _currentUserProfile = null;  
    emit(Unauthenticated());
  }

  //Forgot password
  Future<String> forgotPassword(String email) async {
    try{
      final message = await authRepo.sendPasswordResetEmail(email);
      return message;
    }
    catch(e){ 
      return e.toString();
      }
  }

  //Delete account
  Future<void> deleteAccount() async {
    try{
      emit(AuthLoading());
      await authRepo.deleteAccount();
      _currentUser = null;
      _currentUserProfile = null;
      emit(Unauthenticated());
    }
    catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      // Gọi UserService để update
      await userService.updateUserProfile(
        uid: _currentUser!.uid,
        name: name,
        phone: phone,
        address: address,
      );

      // Load lại profile từ Firestore để cập nhật state
      _currentUserProfile = await userService.getUserProfile(_currentUser!.uid);
      
      // Emit Authenticated state để UI update
      emit(Authenticated(_currentUser!));
    } catch (e) {
      emit(AuthError('Lỗi cập nhật profile: $e'));
      emit(Authenticated(_currentUser!));
    }
  }

}