// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Like {
  final int id;
  final int uid;
  final int pid;
  final DateTime created_at;
  Like({
    required this.id,
    required this.uid,
    required this.pid,
    required this.created_at,
  });

  Like copyWith({int? id, int? uid, int? pid, DateTime? created_at}) {
    return Like(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      pid: pid ?? this.pid,
      created_at: created_at ?? this.created_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'pid': pid,
      'created_at': created_at.toIso8601String(),
    };
  }

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      id: map['id'] as int,
      uid: map['uid'] as int,
      pid: map['pid'] as int,
      //created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      created_at: DateTime.parse(map['created_at'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Like.fromJson(String source) =>
      Like.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Like(id: $id, uid: $uid, pid: $pid, created_at: $created_at)';
  }

  @override
  bool operator ==(covariant Like other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.uid == uid &&
        other.pid == pid &&
        other.created_at == created_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^ uid.hashCode ^ pid.hashCode ^ created_at.hashCode;
  }
}
