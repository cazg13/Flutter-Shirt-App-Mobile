import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/bloc/shirt_event.dart';
import 'package:flutter_clothingapp/bloc/shirt_state.dart';
import 'package:flutter_clothingapp/models/shirt.dart';
import 'package:flutter_clothingapp/repositories/shirt_repository.dart';

class ShirtBloc extends Bloc<ShirtEvent, ShirtState> {
  final ShirtRepository shirtRepository;

  ShirtBloc(this.shirtRepository) : super(const ShirtInitial()) {
    on<FetchAllShirtsEvent>(_onFetchAllShirts);
    on<FetchShirtByIdEvent>(_onFetchShirtById);
  }

  /// Lấy tất cả giày
  Future<void> _onFetchAllShirts(
    FetchAllShirtsEvent event,
    Emitter<ShirtState> emit,
  ) async {
    try {
      emit(const ShirtLoading());
      List<Shirt> shirts = await shirtRepository.getAllShirts();
      emit(ShirtLoaded(shirts));
    } catch (e) {
      emit(ShirtError('Lỗi tải giày: $e'));
    }
  }

  /// Lấy 1 giày theo ID
  Future<void> _onFetchShirtById(
    FetchShirtByIdEvent event,
    Emitter<ShirtState> emit,
  ) async {
    try {
      emit(const ShirtLoading());
      Shirt? shirt = await shirtRepository.getShirtById(event.id);
      if (shirt != null) {
        emit(ShirtSingleLoaded(shirt));
      } else {
        emit(const ShirtError('Không tìm thấy giày'));
      }
    } catch (e) {
      emit(ShirtError('Lỗi: $e'));
    }
  }
}
