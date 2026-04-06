abstract class ShirtEvent {
  const ShirtEvent();
}

class FetchAllShirtsEvent extends ShirtEvent {
  const FetchAllShirtsEvent();
}

class FetchShirtByIdEvent extends ShirtEvent {
  final String id;
  const FetchShirtByIdEvent(this.id);
}
