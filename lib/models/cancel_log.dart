import 'package:cloud_firestore/cloud_firestore.dart';

class CancelLog {
  final String? cancelLogId;    // Document ID (auto-generate)
  final String userId;          // ID khách hàng hủy
  final String orderId;         // ID đơn hàng hủy
  final String cancelReason;    // Lý do hủy: 'Đổi ý', 'Đổi size', 'Không phù hợp', 'Khác'
  final DateTime cancelledAt;   // Ngày giờ hủy
  final String userEmail;       // Email khách hàng (optional, để tham khảo)

  CancelLog({
    this.cancelLogId,
    required this.userId,
    required this.orderId,
    required this.cancelReason,
    required this.cancelledAt,
    required this.userEmail,
  });

  // Convert to JSON để lưu Firebase
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderId': orderId,
      'cancelReason': cancelReason,
      'cancelledAt': Timestamp.fromDate(cancelledAt),
      'userEmail': userEmail,
    };
  }

  // Convert từ Firebase
  factory CancelLog.fromJson(Map<String, dynamic> json, String cancelLogId) {
    return CancelLog(
      cancelLogId: cancelLogId,
      userId: json['userId'] ?? '',
      orderId: json['orderId'] ?? '',
      cancelReason: json['cancelReason'] ?? '',
      cancelledAt: (json['cancelledAt'] as Timestamp).toDate(),
      userEmail: json['userEmail'] ?? '',
    );
  }
}