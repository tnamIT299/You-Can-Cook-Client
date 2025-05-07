import 'package:redux/redux.dart';
import 'actions.dart';
import 'reducers.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/models/Comment.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/services/PostService.dart';
import 'package:you_can_cook/services/ReelService.dart';
import 'package:you_can_cook/services/CommentService.dart';
import 'package:you_can_cook/db/db.dart';

void appMiddleware(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) async {
  if (action is FetchUserInfo) {
    store.dispatch(SetLoading(true));
    try {
      final userService = UserService();
      final userInfo = await userService.getUserInfo(action.email);
      store.dispatch(SetUserInfo(userInfo));
      store.dispatch(SetLoading(false));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
      store.dispatch(SetLoading(false));
    }
  } else if (action is UpdateUserInfo) {
    try {
      final userService = UserService();
      await userService.updateUserInfo(action.email, action.updates);
      store.dispatch(FetchUserInfo(action.email));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
    }
  } else if (action is FetchUserPostsAndPhotos) {
    store.dispatch(SetLoading(true));
    try {
      final postService = PostService(supabaseClient);
      final reelService = ReelService();
      final posts = await postService.fetchPostsByUid(action.uid);
      final photos = await postService.fetchImagesByUid(action.uid);
      final videos = await reelService.fetchVideosByUid(action.uid);
      store.dispatch(SetUserPosts(posts));
      store.dispatch(SetUserPhotos(photos));
      store.dispatch(SetUserVideos(videos));
      store.dispatch(SetLoading(false));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
      store.dispatch(SetLoading(false));
    }
  } else if (action is FetchUserInfoById) {
    store.dispatch(SetLoading(true));
    try {
      final userService = UserService();
      final userInfo = await userService.getUserInfoById(action.userId);
      store.dispatch(SetUserInfo(userInfo));
      store.dispatch(SetLoading(false));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
      store.dispatch(SetLoading(false));
    }
  } else if (action is FetchProfileUserInfo) {
    store.dispatch(SetLoading(true));
    try {
      final userService = UserService();
      final userInfo = await userService.getUserInfoById(action.userId);
      store.dispatch(SetProfileUserInfo(userInfo));
      store.dispatch(SetLoading(false));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
      store.dispatch(SetLoading(false));
    }
  } else if (action is FetchComments) {
    store.dispatch(SetLoading(true));
    try {
      final commentService = CommentService(supabaseClient);
      final userService = UserService();
      final currentUserId = await userService.getCurrentUserUid() ?? 0;
      final comments = await commentService.getCommentsByPostId(
        action.postId,
        limit: action.limit,
        offset: action.offset,
        currentUserId: currentUserId,
      );
      store.dispatch(SetComments(action.postId, comments));
      store.dispatch(SetLoading(false));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
      store.dispatch(SetLoading(false));
    }
  } else if (action is FetchComments) {
    store.dispatch(SetLoading(true));
    try {
      final commentService = CommentService(supabaseClient);
      final userService = UserService();
      final currentUserId = await userService.getCurrentUserUid() ?? 0;
      final comments = await commentService.getCommentsByPostId(
        action.postId,
        limit: action.limit,
        offset: action.offset,
        currentUserId: currentUserId,
      );
      store.dispatch(SetComments(action.postId, comments));
      store.dispatch(SetLoading(false));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
      store.dispatch(SetLoading(false));
    }
  } else if (action is ToggleCommentLike) {
    store.dispatch(SetLoading(true));
    try {
      final commentService = CommentService(supabaseClient);
      final userService = UserService();
      final userId = await userService.getCurrentUserUid();
      if (userId == null) {
        store.dispatch(SetError("User not logged in"));
        store.dispatch(SetLoading(false));
        return;
      }
      int newLikeCount;
      if (action.isLiked) {
        newLikeCount = await commentService.likeComment(
          action.commentId,
          userId,
        );
      } else {
        newLikeCount = await commentService.unlikeComment(
          action.commentId,
          userId,
        );
      }
      // Update the specific comment in the store
      final newComments = Map<int, List<Comment>>.from(
        store.state.postComments,
      );
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
          likeCount: newLikeCount,
          isLiked: action.isLiked,
        );
      }
      newComments[action.postId] = comments;
      store.dispatch(SetComments(action.postId, comments));
      store.dispatch(SetLoading(false));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
      store.dispatch(SetLoading(false));
    }
  }
  next(action);
}
