import 'dart:convert';

class Notification {
  final int id;
  final int receiver_uid;
  final int? sender_uid;
  final String type;
  final int? pid;
  final String? content;
  final bool is_read;
  final DateTime created_at;
  final DateTime? updated_at;
  Notification({
    required this.id,
    required this.receiver_uid,
    this.sender_uid,
    required this.type,
    this.pid,
    this.content,
    required this.is_read,
    required this.created_at,
    this.updated_at,
  });

  Notification copyWith({
    int? id,
    int? receiver_uid,
    int? sender_uid,
    String? type,
    int? pid,
    String? content,
    bool? is_read,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return Notification(
      id: id ?? this.id,
      receiver_uid: receiver_uid ?? this.receiver_uid,
      sender_uid: sender_uid ?? this.sender_uid,
      type: type ?? this.type,
      pid: pid ?? this.pid,
      content: content ?? this.content,
      is_read: is_read ?? this.is_read,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'receiver_uid': receiver_uid,
      'sender_uid': sender_uid,
      'type': type,
      'pid': pid,
      'content': content,
      'is_read': is_read,
      'created_at': created_at.millisecondsSinceEpoch,
      'updated_at': updated_at?.millisecondsSinceEpoch,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as int,
      receiver_uid: map['receiver_uid'] as int,
      sender_uid: map['sender_uid'] != null ? map['sender_uid'] as int : null,
      type: map['type'] as String,
      pid: map['pid'] != null ? map['pid'] as int : null,
      content: map['content'] != null ? map['content'] as String : null,
      is_read: map['is_read'] as bool,
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updated_at:
          map['updated_at'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Notification.fromJson(String source) =>
      Notification.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Notification(id: $id, receiver_uid: $receiver_uid, sender_uid: $sender_uid, type: $type, pid: $pid, content: $content, is_read: $is_read, created_at: $created_at, updated_at: $updated_at)';
  }

  @override
  bool operator ==(covariant Notification other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.receiver_uid == receiver_uid &&
        other.sender_uid == sender_uid &&
        other.type == type &&
        other.pid == pid &&
        other.content == content &&
        other.is_read == is_read &&
        other.created_at == created_at &&
        other.updated_at == updated_at;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        receiver_uid.hashCode ^
        sender_uid.hashCode ^
        type.hashCode ^
        pid.hashCode ^
        content.hashCode ^
        is_read.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode;
  }
}
