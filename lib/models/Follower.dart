// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Post {
  final int? id;
  final int follower_id;
  final int following_id;
  Post({this.id, required this.follower_id, required this.following_id});

  Post copyWith({int? id, int? follower_id, int? following_id}) {
    return Post(
      id: id ?? this.id,
      follower_id: follower_id ?? this.follower_id,
      following_id: following_id ?? this.following_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'follower_id': follower_id,
      'following_id': following_id,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] != null ? map['id'] as int : null,
      follower_id: map['follower_id'] as int,
      following_id: map['following_id'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Post(id: $id, follower_id: $follower_id, following_id: $following_id)';

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.follower_id == follower_id &&
        other.following_id == following_id;
  }

  @override
  int get hashCode =>
      id.hashCode ^ follower_id.hashCode ^ following_id.hashCode;
}
