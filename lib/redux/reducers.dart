import 'package:redux/redux.dart';
import 'actions.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/models/Comment.dart';

class AppState {
  final dynamic userInfo;
  final dynamic profileUserInfo;
  final bool isLoading;
  final String? errorMessage;
  final List<Post> userPosts;
  final List<String> userPhotos;
  final Map<int, List<Comment>> postComments;

  AppState({
    this.userInfo,
    this.profileUserInfo,
    this.isLoading = false,
    this.errorMessage,
    this.userPosts = const [],
    this.userPhotos = const [],
    this.postComments = const {},
  });

  AppState copyWith({
    dynamic userInfo,
    dynamic profileUserInfo,
    bool? isLoading,
    String? errorMessage,
    List<Post>? userPosts,
    List<String>? userPhotos,
    Map<int, List<Comment>>? postComments,
  }) {
    return AppState(
      userInfo: userInfo ?? this.userInfo,
      profileUserInfo: profileUserInfo ?? this.profileUserInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userPosts: userPosts ?? this.userPosts,
      userPhotos: userPhotos ?? this.userPhotos,
      postComments: postComments ?? this.postComments,
    );
  }
}

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserInfo) {
    return state.copyWith(userInfo: action.userInfo, isLoading: false);
  } else if (action is SetProfileUserInfo) {
    return state.copyWith(profileUserInfo: action.userInfo, isLoading: false);
  } else if (action is ClearUserInfo) {
    return state.copyWith(
      userInfo: null,
      profileUserInfo: null,
      userPosts: [],
      userPhotos: [],
      postComments: {},
    );
  } else if (action is ClearComments) {
    return state.copyWith(postComments: {});
  } else if (action is SetLoading) {
    return state.copyWith(isLoading: action.isLoading);
  } else if (action is SetError) {
    return state.copyWith(errorMessage: action.errorMessage, isLoading: false);
  } else if (action is SetUserPosts) {
    return state.copyWith(userPosts: action.posts, isLoading: false);
  } else if (action is SetUserPhotos) {
    return state.copyWith(userPhotos: action.photos, isLoading: false);
  } else if (action is DeleteUserPhoto) {
    return state.copyWith(
      userPhotos: List.from(state.userPhotos)..remove(action.photoUrl),
    );
  } else if (action is SetComments) {
    final newComments = Map<int, List<Comment>>.from(state.postComments);
    newComments[action.postId] = action.comments;
    return state.copyWith(postComments: newComments, isLoading: false);
  } else if (action is ToggleCommentLike) {
    final newComments = Map<int, List<Comment>>.from(state.postComments);
    final comments = List<Comment>.from(newComments[action.postId] ?? []);
    final index = comments.indexWhere((c) => c.id == action.commentId);
    if (index != -1) {
      final comment = comments[index];
      comments[index] = Comment(
        id: comment.id,
        userId: comment.userId,
        postId: comment.postId,
        content: comment.content,
        createdAt: comment.createdAt,
        name: comment.name,
        nickname: comment.nickname,
        avatar: comment.avatar,
        likeCount: action.isLiked ? comment.likeCount : comment.likeCount,
        isLiked: action.isLiked,
      );
    }
    newComments[action.postId] = comments;
    return state.copyWith(postComments: newComments);
  }
  return state;
}
