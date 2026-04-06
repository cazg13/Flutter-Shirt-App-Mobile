import 'package:flutter_clothingapp/models/shoe.dart';

abstract class ShoeState {
  const ShoeState();
}

class ShoeInitial extends ShoeState {
  const ShoeInitial();
}

class ShoeLoading extends ShoeState {
  const ShoeLoading();
}

class ShoeLoaded extends ShoeState {
  final List<Shoe> shoes;
  const ShoeLoaded(this.shoes);
}

class ShoeSingleLoaded extends ShoeState {
  final Shoe shoe;
  const ShoeSingleLoaded(this.shoe);
}

class ShoeError extends ShoeState {
  final String message;
  const ShoeError(this.message);
}
