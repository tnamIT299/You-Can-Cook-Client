// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Reel {
  final int? reel_id;
  final int? uid;
  final String? reelContent;
  final String reelUrl;
  final String? thumbnailUrl;
  final List<String>? reelHashtag;
  final int? reelLike;
  final int? reelComment;
  final int? reelSave;
  final String? reelRange;
  final DateTime? createAt;
  final String? nickname; // Từ bảng users
  final String? name;
  final String? avatar; // Từ bảng users
  final bool? isWarning;
  Reel({
    this.reel_id,
    this.uid,
    this.reelContent,
    required this.reelUrl,
    this.thumbnailUrl,
    this.reelHashtag,
    this.reelLike,
    this.reelComment,
    this.reelSave,
    this.reelRange,
    this.createAt,
    this.nickname,
    this.name,
    this.avatar,
    this.isWarning,
  });

  Reel copyWith({
    int? reel_id,
    int? uid,
    String? reelContent,
    String? reelUrl,
    String? thumbnailUrl,
    List<String>? reelHashtag,
    int? reelLike,
    int? reelComment,
    int? reelSave,
    String? reelRange,
    DateTime? createAt,
    String? nickname,
    String? name,
    String? avatar,
    bool? isWarning,
  }) {
    return Reel(
      reel_id: reel_id ?? this.reel_id,
      uid: uid ?? this.uid,
      reelContent: reelContent ?? this.reelContent,
      reelUrl: reelUrl ?? this.reelUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      reelHashtag: reelHashtag ?? this.reelHashtag,
      reelLike: reelLike ?? this.reelLike,
      reelComment: reelComment ?? this.reelComment,
      reelSave: reelSave ?? this.reelSave,
      reelRange: reelRange ?? this.reelRange,
      createAt: createAt ?? this.createAt,
      nickname: nickname ?? this.nickname,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isWarning: isWarning ?? this.isWarning,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reel_id': reel_id,
      'uid': uid,
      'reelContent': reelContent,
      'reelUrl': reelUrl,
      'thumbnailUrl': thumbnailUrl,
      'reelHashtag': reelHashtag,
      'reelLike': reelLike,
      'reelComment': reelComment,
      'reelSave': reelSave,
      'reelRange': reelRange,
      'createAt': createAt?.millisecondsSinceEpoch,
      'nickname': nickname,
      'name': name,
      'avatar': avatar,
      'isWarning': isWarning,
    };
  }

  factory Reel.fromMap(Map<String, dynamic> map) {
    return Reel(
      reel_id: map['reel_id'] != null ? map['reel_id'] as int : null,
      uid: map['uid'] as int,
      reelContent:
          map['reelContent'] != null ? map['reelContent'] as String : null,
      reelUrl: map['reelUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      reelHashtag:
          map['reelHashtag'] != null
              ? (map['reelHashtag'] is String
                  ? jsonDecode(
                    map['reelHashtag'] as String,
                  ).map<String>((e) => e as String).toList()
                  : List<String>.from(map['reelHashtag'] as List))
              : null,
      reelLike: map['reelLike'] != null ? map['reelLike'] as int : null,
      reelComment:
          map['reelComment'] != null ? map['reelComment'] as int : null,
      reelSave: map['reelSave'] != null ? map['reelSave'] as int : null,
      reelRange: map['reelRange'] != null ? map['reelRange'] as String : null,
      createAt:
          map['createAt'] != null
              ? DateTime.parse(map['createAt'] as String)
              : null,
      nickname:
          map['users'] != null && map['users']['nickname'] != null
              ? map['users']['nickname'].toString()
              : null,
      name:
          map['users'] != null && map['users']['name'] != null
              ? map['users']['name'].toString()
              : null,
      avatar:
          map['users'] != null && map['users']['avatar'] != null
              ? map['users']['avatar'].toString()
              : null,
      isWarning: map['isWarning'] != null ? map['isWarning'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reel.fromJson(String source) =>
      Reel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Reel(reel_id: $reel_id, uid: $uid, reelContent: $reelContent, reelUrl: $reelUrl,thumbnailUrl:$thumbnailUrl , reelHashtag: $reelHashtag, reelLike: $reelLike, reelComment: $reelComment, reelSave: $reelSave, reelRange: $reelRange, createAt: $createAt, nickname: $nickname, name: $name, avatar: $avatar, isWarning: $isWarning)';
  }

  @override
  bool operator ==(covariant Reel other) {
    if (identical(this, other)) return true;

    return other.reel_id == reel_id &&
        other.uid == uid &&
        other.reelContent == reelContent &&
        other.reelUrl == reelUrl &&
        other.thumbnailUrl == thumbnailUrl &&
        listEquals(other.reelHashtag, reelHashtag) &&
        other.reelLike == reelLike &&
        other.reelComment == reelComment &&
        other.reelSave == reelSave &&
        other.reelRange == reelRange &&
        other.createAt == createAt &&
        other.nickname == nickname &&
        other.name == name &&
        other.avatar == avatar &&
        other.isWarning == isWarning;
  }

  @override
  int get hashCode {
    return reel_id.hashCode ^
        uid.hashCode ^
        reelContent.hashCode ^
        reelUrl.hashCode ^
        thumbnailUrl.hashCode ^
        reelHashtag.hashCode ^
        reelLike.hashCode ^
        reelComment.hashCode ^
        reelSave.hashCode ^
        reelRange.hashCode ^
        createAt.hashCode ^
        nickname.hashCode ^
        name.hashCode ^
        avatar.hashCode ^
        isWarning.hashCode;
  }
}
