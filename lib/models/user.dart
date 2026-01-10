class User {
  final String id;
  final String firebaseUid;
  final String email;
  final String? name;
  final String? imageUrl;
  final int createdAt;
  final int updatedAt;

  User({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.name,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      firebaseUid: json['firebaseUid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
