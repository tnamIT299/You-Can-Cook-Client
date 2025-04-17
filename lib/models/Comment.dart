class Comment {
  final int id;
  final int userId;
  final int postId;
  final String content;
  final DateTime createdAt;
  final String? avatar;
  final String? nickname;
  final String? name;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    this.avatar,
    this.nickname,
    this.name,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as int,
      userId: map['uid'] as int,
      postId: map['pid'] as int,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      avatar: map['users']?['avatar'] as String?,
      nickname: map['users']?['nickname'] as String?,
      name: map['users']?['name'] as String?,
    );
  }
}
