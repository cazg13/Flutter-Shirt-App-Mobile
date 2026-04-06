/*
Auth states
*/

import 'package:flutter_clothingapp/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

//initial state

class AuthInitial extends AuthState {}

//loading state
class AuthLoading extends AuthState {}

//authenticated state
class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

//Unauthenticated state
class Unauthenticated extends AuthState {}

//errors  
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

//registration success state
class RegisterSuccess extends AuthState {
  final String message;
  RegisterSuccess(this.message);
}