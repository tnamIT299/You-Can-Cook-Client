import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/models/Comment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/db/db.dart';
import 'package:you_can_cook/models/Reel.dart';

class FetchUserInfo {
  final String email;
  FetchUserInfo(this.email);
}

class FetchTotalLikes {
  final int totalLikes;

  FetchTotalLikes(this.totalLikes);
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

class ClearUserInfo {
  ClearUserInfo();
}

class SetLoading {
  final bool isLoading;
  SetLoading(this.isLoading);
}

class SetError {
  final String errorMessage;
  SetError(this.errorMessage);
}

class SetUserPosts {
  final List<Post> posts;
  SetUserPosts(this.posts);
}

class SetUserPhotos {
  final List<String> photos;
  SetUserPhotos(this.photos);
}

class SetUserVideos {
  final List<Reel> videos;
  SetUserVideos(this.videos);
}

class FetchUserPostsAndPhotos {
  final int uid;
  FetchUserPostsAndPhotos(this.uid);
}

class FetchUserInfoById {
  final int userId;
  FetchUserInfoById(this.userId);
}

class FetchProfileUserInfo {
  final int userId;
  FetchProfileUserInfo(this.userId);
}

class SetProfileUserInfo {
  final dynamic userInfo;
  SetProfileUserInfo(this.userInfo);
}

class DeleteUserPhoto {
  final String photoUrl;
  DeleteUserPhoto(this.photoUrl);
}

class FetchComments {
  final int postId;
  final int limit;
  final int offset;
  FetchComments(this.postId, {this.limit = 8, this.offset = 0});
}

class SetComments {
  final int postId;
  final List<Comment> comments;
  SetComments(this.postId, this.comments);
}

class ToggleCommentLike {
  final int postId;
  final int commentId;
  final bool isLiked;
  ToggleCommentLike(this.postId, this.commentId, this.isLiked);
}

class ClearComments {
  ClearComments();
}
