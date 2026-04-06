import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/bloc/shoe_event.dart';
import 'package:flutter_clothingapp/bloc/shoe_state.dart';
import 'package:flutter_clothingapp/models/shoe.dart';
import 'package:flutter_clothingapp/repositories/shoe_repository.dart';

class ShoeBloc extends Bloc<ShoeEvent, ShoeState> {
  final ShoeRepository shoeRepository;

  ShoeBloc(this.shoeRepository) : super(const ShoeInitial()) {
    on<FetchAllShoesEvent>(_onFetchAllShoes);
    on<FetchShoeByIdEvent>(_onFetchShoeById);
  }

  /// Lấy tất cả giày
  Future<void> _onFetchAllShoes(
    FetchAllShoesEvent event,
    Emitter<ShoeState> emit,
  ) async {
    try {
      emit(const ShoeLoading());
      List<Shoe> shoes = await shoeRepository.getAllShoes();
      emit(ShoeLoaded(shoes));
    } catch (e) {
      emit(ShoeError('Lỗi tải giày: $e'));
    }
  }

  /// Lấy 1 giày theo ID
  Future<void> _onFetchShoeById(
    FetchShoeByIdEvent event,
    Emitter<ShoeState> emit,
  ) async {
    try {
      emit(const ShoeLoading());
      Shoe? shoe = await shoeRepository.getShoeById(event.id);
      if (shoe != null) {
        emit(ShoeSingleLoaded(shoe));
      } else {
        emit(const ShoeError('Không tìm thấy giày'));
      }
    } catch (e) {
      emit(ShoeError('Lỗi: $e'));
    }
  }
}
