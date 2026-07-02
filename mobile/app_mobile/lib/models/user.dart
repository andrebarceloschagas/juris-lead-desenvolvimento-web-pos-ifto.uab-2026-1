class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'bio': bio,
    };
  }
}
