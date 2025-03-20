import 'package:you_can_cook/models/Post.dart';

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

// Thêm các hành động để quản lý trạng thái bài đăng
class SetUserPosts {
  final List<Post> posts;

  SetUserPosts(this.posts);
}

class SetUserPhotos {
  final List<String> photos;

  SetUserPhotos(this.photos);
}

class FetchUserPostsAndPhotos {
  final int uid;

  FetchUserPostsAndPhotos(this.uid);
}
