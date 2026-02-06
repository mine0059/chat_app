class ProfileState {
  ProfileState({
    this.photoUrl,
    this.name,
    this.createdAt,
    this.email,
    // this.isLoading = false,
    this.isUploading = false,
    this.userId,
  });

  ProfileState copyWith({
    String? photoUrl,
    String? name,
    DateTime? createdAt,
    String? email,
    // bool? isLoading,
    bool? isUploading,
    String? userId,
  }) {
    return ProfileState(
      photoUrl: photoUrl ?? this.photoUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      // isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      userId: userId ?? this.userId,
    );
  }

  final String? photoUrl;
  final String? name;
  final String? email;
  // final bool isLoading;
  final bool isUploading;
  final DateTime? createdAt;
  final String? userId; // this is to track current user
}