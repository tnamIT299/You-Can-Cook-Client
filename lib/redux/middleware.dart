import 'package:redux/redux.dart';
import 'actions.dart';
import 'reducers.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/services/PostService.dart';
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
    } catch (e) {
      store.dispatch(SetError(e.toString()));
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
      final posts = await postService.fetchPostsByUid(action.uid);
      final photos = await postService.fetchImagesByUid(action.uid);
      store.dispatch(SetUserPosts(posts));
      store.dispatch(SetUserPhotos(photos));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
    }
  } else if (action is FetchUserInfoById) {
    store.dispatch(SetLoading(true));
    try {
      final userService = UserService();
      final userInfo = await userService.getUserInfoById(action.userId);
      store.dispatch(SetUserInfo(userInfo));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
    }
  } else if (action is FetchProfileUserInfo) {
    store.dispatch(SetLoading(true));
    try {
      final userService = UserService();
      final userInfo = await userService.getUserInfoById(action.userId);
      store.dispatch(SetProfileUserInfo(userInfo));
    } catch (e) {
      store.dispatch(SetError(e.toString()));
    }
  }
  next(action);
}
