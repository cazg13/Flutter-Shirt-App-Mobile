import 'package:cloud_firestore/cloud_firestore.dart';

class ImportStockLog {
  final String id;
  final String productId;        // ID sản phẩm (shirt data id)
  final int stockAdded;          // Số lượng nhập
  final DateTime importedAt;     // Ngày giờ nhập
  final String adminEmail;       // Email của admin nhập

  ImportStockLog({
    required this.id,
    required this.productId,
    required this.stockAdded,
    required this.importedAt,
    required this.adminEmail,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'stockAdded': stockAdded,
      'importedAt': Timestamp.fromDate(importedAt),
      'adminEmail': adminEmail,
    };
  }

  // Create from JSON
  factory ImportStockLog.fromJson(Map<String, dynamic> json, String id) {
    return ImportStockLog(
      id: id,
      productId: json['productId'] ?? '',
      stockAdded: json['stockAdded'] ?? 0,
      importedAt: (json['importedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adminEmail: json['adminEmail'] ?? '',
    );
  }
}