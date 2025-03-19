class FetchUserInfo {
  final String email;

  FetchUserInfo(this.email);
}

class UpdateUserInfo {
  final String email;
  final Map<String, dynamic> updates;

  UpdateUserInfo(this.email, this.updates);
}

class SetUserInfo {
  final dynamic userInfo;

  SetUserInfo(this.userInfo);
}

class SetLoading {
  final bool isLoading;

  SetLoading(this.isLoading);
}

class SetError {
  final String errorMessage;

  SetError(this.errorMessage);
}
