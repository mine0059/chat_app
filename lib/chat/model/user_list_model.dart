class UserListTileState {
  const UserListTileState({
    this.areFriends = false,
    this.requestStatus,
    this.isRequestSender = false,
    this.pendingRequestId,
  });

  UserListTileState copyWith({
    bool? isLoading,
    String? requestStatus,
    bool? areFriends,
    bool? isRequestSender,
    String? pendingRequestId,
  }) {
    return UserListTileState(
      isRequestSender: isRequestSender ?? this.isRequestSender,
      requestStatus: requestStatus ?? this.requestStatus,
      areFriends: areFriends ?? this.areFriends,
      pendingRequestId: pendingRequestId ?? this.pendingRequestId,
    );
  }

  final String? requestStatus;
  final bool areFriends;
  final bool isRequestSender;
  final String? pendingRequestId;
}