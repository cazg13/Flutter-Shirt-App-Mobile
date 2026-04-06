class Shirt {
  final String id;
  final String name;
  final String price;
  final String description;
  final String imageUrl;
  final int stock;
  final List<String> sizes;  // Thêm dòng này
  String? selectedSize;  // Thêm dòng này để lưu size đã chọn
  int quantity; 
  

  Shirt({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.stock,
    required this.sizes,  // Thêm dòng này
    this.selectedSize,  // Thêm dòng này
    this.quantity = 1,
  });

  /// Chuyển data từ Firestore thành Shirt object
  factory Shirt.fromFirebase(Map<String, dynamic> data, String id) {
    return Shirt(
      id: data['id'] ?? id,  // Sử dụng id từ document nếu có, nếu không thì dùng id truyền vào
      name: data['name'] ?? '',
      price: data['price']?.toString() ?? '0',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      stock: data['stock'] ?? 0,
      sizes: List<String>.from(data['sizes'] ?? []),  // Thêm dòng này
    );
  }

  /// Chuyển Shirt object thành data để lưu Firestore
  Map<String, dynamic> toFirebase() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'stock': stock,
      'sizes': sizes,  // Thêm dòng này
    };
  }
}