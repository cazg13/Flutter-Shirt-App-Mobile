class UserProfile {
  final String uid;
  final String email;
  final String role;
  final DateTime createdAt;
  final String name;
  final String phone;
  final String address;

  UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.name,
    required this.phone,
    required this.address,
  });

  // Convert UserProfile -> JSON (để lưu vào Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': createdAt,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  // Convert JSON -> UserProfile (để lấy từ Firestore)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}