import 'package:redux/redux.dart';
import 'actions.dart';
import 'package:you_can_cook/models/Post.dart'; // Đảm bảo import model Post

class AppState {
  final dynamic userInfo;
  final bool isLoading;
  final String? errorMessage;
  final List<Post> userPosts;
  final List<String> userPhotos;

  AppState({
    this.userInfo,
    this.isLoading = false,
    this.errorMessage,
    this.userPosts = const [],
    this.userPhotos = const [],
  });

  AppState copyWith({
    dynamic userInfo,
    bool? isLoading,
    String? errorMessage,
    List<Post>? userPosts,
    List<String>? userPhotos,
  }) {
    return AppState(
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userPosts: userPosts ?? this.userPosts,
      userPhotos: userPhotos ?? this.userPhotos,
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserInfo) {
    return state.copyWith(userInfo: action.userInfo, isLoading: false);
  } else if (action is ClearUserInfo) {
    return state.copyWith(userInfo: null, userPosts: [], userPhotos: []);
  } else if (action is SetLoading) {
    return state.copyWith(isLoading: action.isLoading);
  } else if (action is SetError) {
    return state.copyWith(errorMessage: action.errorMessage, isLoading: false);
  } else if (action is SetUserPosts) {
    return state.copyWith(userPosts: action.posts, isLoading: false);
  } else if (action is SetUserPhotos) {
    return state.copyWith(userPhotos: action.photos, isLoading: false);
  }
  return state;
}
