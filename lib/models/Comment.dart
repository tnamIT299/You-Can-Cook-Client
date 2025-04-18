// class Comment {
//   final int id;
//   final int userId;
//   final int postId;
//   final String content;
//   final String? imageURL;
//   final String? gifURL;
//   final DateTime createdAt;
//   final String? avatar;
//   final String? nickname;
//   final String? name;

//   Comment({
//     required this.id,
//     required this.userId,
//     required this.postId,
//     required this.content,
//     this.imageURL,
//     this.gifURL,
//     required this.createdAt,
//     this.avatar,
//     this.nickname,
//     this.name,
//   });

//   factory Comment.fromMap(Map<String, dynamic> map) {
//     return Comment(
//       id: map['id'] as int,
//       userId: map['uid'] as int,
//       postId: map['pid'] as int,
//       content: map['content'] as String,
//       imageURL: map['imageURL'] as String?,
//       gifURL: map['gifURL'] as String?,
//       createdAt: DateTime.parse(map['created_at'] as String),
//       avatar: map['users']?['avatar'] as String?,
//       nickname: map['users']?['nickname'] as String?,
//       name: map['users']?['name'] as String?,
//     );
//   }
// }
class Comment {
  final int id;
  final int userId;
  final int postId;
  final String content;
  final String? imageURL;
  final String? gifURL;
  final DateTime createdAt;
  final String? avatar;
  final String? nickname;
  final String? name;
  final int likeCount; // Số lượt thích
  final bool isLiked; // Trạng thái đã thích bởi người dùng hiện tại

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    this.imageURL,
    this.gifURL,
    required this.createdAt,
    this.avatar,
    this.nickname,
    this.name,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as int,
      userId: map['uid'] as int,
      postId: map['pid'] as int,
      content: map['content'] as String,
      imageURL: map['imageURL'] as String?,
      gifURL: map['gifURL'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      avatar: map['users']?['avatar'] as String?,
      nickname: map['users']?['nickname'] as String?,
      name: map['users']?['name'] as String?,
      likeCount: map['like_count'] as int? ?? 0,
      isLiked: map['is_liked'] as bool? ?? false,
    );
  }
}
