class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
  });
  final String id;
  final String email;
  final String name;
  final String? avatar;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.avatar == avatar;
  }

  @override
  int get hashCode =>
      id.hashCode ^ email.hashCode ^ name.hashCode ^ avatar.hashCode;
}
