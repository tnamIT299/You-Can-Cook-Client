import 'package:supabase_flutter/supabase_flutter.dart';

class Comment {
  final int id;
  final int userId;
  final int postId;
  final String content;
  final DateTime createdAt;
  final String? name;
  final String? nickname;
  final String? avatar;
  final int likeCount; // New field for like count
  final bool isLiked; // New field for liked state

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    this.name,
    this.nickname,
    this.avatar,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? 0,
      userId: map['uid'] ?? map['users']['uid'] ?? 0,
      postId: map['pid'] ?? 0,
      content: map['content'] ?? '',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      name: map['users'] != null ? map['users']['name'] : map['name'],
      nickname:
          map['users'] != null ? map['users']['nickname'] : map['nickname'],
      avatar: map['users'] != null ? map['users']['avatar'] : map['avatar'],
      likeCount: map['like_count'] ?? 0,
      isLiked: map['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': userId,
      'pid': postId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'nickname': nickname,
      'avatar': avatar,
      'like_count': likeCount,
      'is_liked': isLiked,
    };
  }
}
