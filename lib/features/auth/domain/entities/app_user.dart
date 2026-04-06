class AppUser {
  final String uid;
  final String email;

  AppUser({required this.uid, required this.email});

  //convert AppUser -> json
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
    };
  }

  //convert json -> AppUser
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
    );
  }
}