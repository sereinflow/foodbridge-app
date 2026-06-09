class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;

  final String? phone;
  final String? bio;
  final List<String> savedPosts;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.bio,
    this.savedPosts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'bio': bio,
      'savedPosts': savedPosts,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      phone: map['phone'] ?? '',
      bio: map['bio'] ?? '',
      savedPosts: List<String>.from(map['savedPosts'] ?? []),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? bio,
    List<String>? savedPosts,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      savedPosts: savedPosts ?? this.savedPosts,
    );
  }
}
