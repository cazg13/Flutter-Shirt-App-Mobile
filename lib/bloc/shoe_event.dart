abstract class ShoeEvent {
  const ShoeEvent();
}

class FetchAllShoesEvent extends ShoeEvent {
  const FetchAllShoesEvent();
}

class FetchShoeByIdEvent extends ShoeEvent {
  final String id;
  const FetchShoeByIdEvent(this.id);
}
