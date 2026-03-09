class User {
  String id;
  String name;
  String email;
  String? profileImage;
  DateTime createdAt;
  Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdAt,
    this.preferences = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'createdAt': createdAt.toIso8601String(),
        'preferences': preferences,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profileImage: json['profileImage'],
        createdAt: DateTime.parse(json['createdAt']),
        preferences: json['preferences'] ?? {},
      );
}