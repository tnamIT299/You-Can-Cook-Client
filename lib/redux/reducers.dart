import 'package:redux/redux.dart';
import 'actions.dart';

class AppState {
  final dynamic userInfo;
  final bool isLoading;
  final String? errorMessage;

  AppState({this.userInfo, this.isLoading = false, this.errorMessage});

  AppState copyWith({dynamic userInfo, bool? isLoading, String? errorMessage}) {
    return AppState(
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserInfo) {
    return state.copyWith(userInfo: action.userInfo, isLoading: false);
  } else if (action is SetLoading) {
    return state.copyWith(isLoading: action.isLoading);
  } else if (action is SetError) {
    return state.copyWith(errorMessage: action.errorMessage, isLoading: false);
  }
  return state;
}
