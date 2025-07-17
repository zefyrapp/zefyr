class EditProfileState {
  const EditProfileState({
    this.avatar,
    this.name,
    this.nickname,
    this.bio,
    this.isLoading = false,
    this.errorMessage,
  });
  final String? avatar; 
  final String? name;
  final String? nickname;
  final String? bio;
  final bool isLoading;
  final String? errorMessage;

  EditProfileState copyWith({
    String? avatar,
    String? name,
    String? nickname,
    String? bio,
    bool? isLoading,
    String? errorMessage,
  }) => EditProfileState(
    avatar: avatar ?? this.avatar,
    name: name ?? this.name,
    nickname: nickname ?? this.nickname,
    bio: bio ?? this.bio,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
