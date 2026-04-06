import 'package:flutter_clothingapp/models/shirt.dart';

abstract class ShirtState {
  const ShirtState();
}

class ShirtInitial extends ShirtState {
  const ShirtInitial();
}

class ShirtLoading extends ShirtState {
  const ShirtLoading();
}

class ShirtLoaded extends ShirtState {
  final List<Shirt> shirts;
  const ShirtLoaded(this.shirts);
}

class ShirtSingleLoaded extends ShirtState {
  final Shirt shirt;
  const ShirtSingleLoaded(this.shirt);
}

class ShirtError extends ShirtState {
  final String message;
  const ShirtError(this.message);
}
